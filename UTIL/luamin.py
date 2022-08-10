#!/usr/bin/python
from re import L
import sys
import os
import json
import itertools
from luaparser import ast
from luaparser import astnodes
from common import getExtension, checkFile, log, makeFileName
#----------------------------------------------------------------------------------------
precedence = {
    'or' : 1,
    'and': 2,
    '<'  : 3, '>': 3, '<=': 3, '>=': 3, '~=': 3, '==': 3,
    '..' : 5,
    '+': 6, '-': 6,
    '*': 7, '/': 7, '%': 7,
    'unarynot': 8, 'unary#': 8, 'unary-': 8,
    '^': 10
}
whiteChars = [' ', '\n', '\t', '\r']

escapeForCharacter = ['\r', '\n', '\t', '"', "'", '\\'];

characterForEscape = ['\r', '\n', '\t', '"', "'", '\\'];

newLineCharacters  = [ '\r', '\n' ];

minNamesList = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 
                'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
                's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];

allIdentStartChars = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 
                      'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
                      's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 
                      'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 
                      'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '_'];

allIdentChars = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 
                 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
                 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 
                 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 
                 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '_',
                 '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

hexDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
             'A', 'a', 'B', 'b', 'C', 'c', 'D', 'd', 'E', 'e', 'F', 'f'];

symbols = ['+', '-', '*', '/', '^', '%', ',', '{', '}', '[', ']', '(', ')', ';', '#', '.', ':'];

equalSymbols = ['~', '=', '>', '<'];

keywords = ['and', 'break', 'do', 'else', 'elseif',
            'end', 'false', 'for', 'function', 'goto', 'if',
            'in', 'local', 'nil', 'not', 'or', 'repeat',
            'return', 'then', 'true', 'until', 'while' ];

blockFollowKeyword = ['else', 'elseif', 'until', 'end'];

unopSet = ['-', 'not', '#']

binopSet = ['+', '-', '*', '/', '%', '^', '#', '..', '.', ':', '>', '<', '<=', '>=', '~=', '==', 'and', 'or'];

binaryPriority = {
  '+'   : [6,  6],
  '-'   : [6,  6],
  '*'   : [7,  7],
  '/'   : [7,  7],
  '%'   : [7,  7],
  '^'   : [10, 9],
  '..'  : [5,  4],
  '=='  : [3,  3],
  '~='  : [3,  3],
  '>'   : [3,  3],
  '<'   : [3,  3],
  '>='  : [3,  3],
  '<='  : [3,  3],
  'and' : [2,  2],
  'or'  : [1,  1]
};

reservedNames = [ 'setmetatable', 'stop', 'self', 'type' ];

unaryPriority = 8;


#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
def analizInput ( args ):
  data = {
    "command" : '',
    "file"    : '',
    "out"     : '',
    "newLine" : False,
    "spaces"  : False,
    "names"   : False,
  }
  for i in range( len( args ) ):
    if args[i] == '-h':
      data['command'] = '-h';
    if ( args[i] == '-s' ) and ( len( args ) > ( i + 1 ) ):
      data['script'] = args[i + 1];
    if ( args[i] == '-o' ) and ( len( args ) > ( i + 1 ) ):
      data['out'] = args[i + 1];
    if ( args[i] == '-a' ):
      data['newLine'] = True;
      data['spaces']  = True;
      data['names']   = True;
    if ( args[i] == '-n' ):
      data['newLine'] = True;
    if ( args[i] == '-sp' ):
      data['spaces']  = True;
    if ( args[i] == '-v' ):
      data['names']   = True;  
  return data;

def checkInputData ( data ):
  error = None;
  if ( data['command'] != '' ) and ( data['command'] != '-h' ):
    error = 'Wrong command';
  if ( error == None ):
    if data['command'] != '-h':
      error = checkFile( data['script'], '.lua' );
      if ( error == None ):
        if ( data['out'] == '' ):
          data['out'] = os.path.join( os.getcwd(), 'out' );
        if not os.path.exists( data['out'] ):
          os.mkdir( data['out'] );  
  return error;

def runCommand ( data ):
  if ( data['command'] == '' ):
    name = luaMinProcessing( data );
    log( 'luamin', 'info', ('DONE: ' + name ) );
  else:
    if ( data['command'] == '-h' ):
      showHelp();
  return;

def showHelp ():
  print( '*************************************************' );
  print( '    -h:  get help information'                     );
  print( '    -s:  set script file'                          );
  print( '    -o:  set output path'                          );
  print( '    -a:  optimise all scenarios'                   );
  print( '    -n:  optimise new line symbols'                );
  print( '    -sp: optimise spaces symbols'                  );
  print( '    -v:  optimise var and functions names'         );
  print( '*************************************************' );
  return;
#----------------------------------------------------------------------------------------
def luaOpenScript ( path ):
  f = open( path, 'r', encoding='utf-8' );
  buffer = f.read();
  f.close();
  return buffer;
#----------------------------------------------------------------------------------------
def luaDeleteComments ( data ):
  out = data;
  while out.find( '--' ) > 0:
    start = out.find( '--' );
    multiline = out[start:].find( '[[' );
    newline   = out[start:].find( '\n' )
    if multiline > 0 and multiline < newline:
      shift = out[start:].find( ']]' ) + 2;
      out   = out[:start] + out[start+shift:];
    else:
      shift = out[start:].find( '\n' ) + 1;
      out   = out[:start] + out[start+shift:];
  return out;

def luaConvertTabsToSpaces ( data ):
  out = data;
  out = out.replace( '\t', ' ' );
  return out;
#----------------------------------------------------------------------------------------
def makeNewMinName ( index ):
  length = 1;
  border = len( minNamesList );
  out    = '';
  shift  = 0;
  while ( index >= border ):
    length += 1;
    border += pow( len( minNamesList ), length )
  border -= pow( len( minNamesList ), length )  
  item    = index;
  for i in range( length ):
    item = item - border + shift;
    if item >= len( minNamesList ):
      shift = item // len( minNamesList );
      item  = item - shift * len( minNamesList );
    else:
      shift = 0
    out     = minNamesList[item] + out;
    item   -= item;
    border -= pow( len( minNamesList ), ( length - i - 1 ) );
  return out;

class Name ():
  def __init__( self, name, isGlobal, className ):
    self.name      = name;
    self.isGlobal  = isGlobal;
    self.className = className;

def getVarName ( name, varList, isGlobal, className, debug=False ):
  out = name;
  if name not in reservedNames:
    index = -1
    for i in range( len( varList ) ):
      if varList[i] != None:
        if varList[i].name == name:
          if className == None or varList[i].className == className:
            index = i;
            break;
    if index == -1:
      varList.append( Name( name, isGlobal, className ) );
      index = len( varList ) - 1;
    out = makeNewMinName( index );  
  return out;

def cleanVarList ( varList ):
  out = [];
  for item in varList:
    if item != None:
      if item.isGlobal == True or item.className != None:
        out.append( item );
      else:
        out.append( None );  
    else:
      out.append( item );    
  return out;    

def isEndPoint ( node ):
  return isinstance( node, astnodes.Index ) or isinstance( node, astnodes.Name );

def processEndPoint ( node, varList, className, debug=False ):
  if isinstance( node, astnodes.Index ):
    if isinstance( node.value, astnodes.Name ):
      if node.value.id == 'self':
        node.idx.id = getVarName( node.idx.id, varList, False, className );
      else:
        if 'id' in dir( node.idx ):
          node.idx.id   = getVarName( node.idx.id, varList, False, node.value.id );
        node.value.id = getVarName( node.value.id, varList, True, None );    
    else:
      processEndPoint( node.value, varList, className, debug );
  elif isinstance( node, astnodes.Name ):
    node.id = getVarName( node.id, varList, False, None, debug ); 
  return node;  

astClassFields = [ 'left', 'right', 'targets', 'values', 'test', 
                   'body', 'orelse', 'target', 'start', 'stop', 
                   'step', 'iter', 'args', 'func', 'fields', 
                   'operand', 'key', 'value'  ];

def processTree ( node, varList, className, debug=False ):
  if isEndPoint( node ):
    processEndPoint( node, varList, className, debug );
  else:
    if type( node ) == list:
      for item in node:
        item = processTree( item, varList, className, debug );
    else:
      for field in astClassFields:
        if field in dir( node ):
          atr = getattr( node, field );
          #if debug == True:
          #  if ( 'id' in dir( atr )):
          #    print( atr.id )
          atr = processTree( atr, varList, className, debug );
  return node;  

def processingMethod ( method, varList ):
  out = method;
  # Set Method name and arguments
  className     = out.source.id;
  methodName    = out.name.id;
  out.source.id = getVarName( out.source.id, varList, True, None );
  out.name.id   = getVarName( out.name.id, varList, False, className );
  
  for arg in out.args:
    if 'id' in dir( arg ):
      arg.id = getVarName( arg.id, varList, False, None )
  
  if methodName == 'new':
    obj = '';
    for node in ast.walk( out ):
      if isinstance( node, astnodes.Call ):
        if node.func.id == 'setmetatable':
          obj = node.args[0].id;
          getVarName( node.args[0].id, varList, False, None )
    isTableNext = False;      
    for node in ast.walk( out ): 
      if isinstance( node, astnodes.Name ):
        if node.id == obj:
          isTableNext = True;
      if isinstance( node, astnodes.Table ) and isTableNext:
        isTableNext = False;
        for field in node.fields:
          getVarName( field.key.id, varList, False, className );
  processTree( out.body, varList, className );
  return out;

def processLuaFunction ( function, varList ):
  out = function;
  out.name.id = getVarName( out.name.id, varList, True, None );
  for arg in out.args:
    arg.id = getVarName( arg.id, varList, False, None );
  processTree( out.body, varList, None );
  return out;

def luaMinNames ( data ):
  out     = data;
  tree    = ast.parse( out );
  varList = [];
  # Walk thrue the blocks of file
  for node in tree.body.body:
    #---------------- Functions ----------------
    if isinstance( node, astnodes.Function ):
      node    = processLuaFunction( node, varList );
      varList = cleanVarList( varList );
    #--------------- Global vars ---------------
    elif isinstance( node, astnodes.Assign ):
      for value in node.values:


        if isinstance( value, astnodes.AnonymousFunction ):
          processTree( value.body, varList, None, True );


        elif isinstance( value, astnodes.Name ):
          value.id = getVarName( value.id, varList, True, None );
      for target in node.targets:
        if isinstance( target, astnodes.Index ):
          target.value.id = getVarName( target.value.id, varList, True, None );
        elif isinstance( target, astnodes.Name ):
          target.id = getVarName( target.id, varList, True, None );
    #-------------- Class methods --------------
    elif isinstance( node, astnodes.Method ):
      node    = processingMethod( node, varList );
      varList = cleanVarList( varList );    
    #-------------------------------------------
  out = ast.to_lua_source( tree );
  return out;

def luaMinSpaces ( data ):
  out     = data;
  minList = list( itertools.chain( equalSymbols, symbols, escapeForCharacter ) );
  while out.find( '  ' ) != -1:
    out = out.replace( '  ', ' ' );
  for symbol in minList:
    out = out.replace( ( ' ' + symbol ), symbol );
    out = out.replace( ( symbol + ' ' ), symbol );  
  return out;

def luaMinNewLines ( data ):
  out = data;
  for item in newLineCharacters:
    out = out.replace( item, ' ' );
  return out;

def luaMinProcessing ( data ):
  buffer = luaOpenScript( data['script'] );
  startSize = len( buffer );
  log( 'luamin', 'info', ('Start size of the script is ' + str( startSize ) + ' byte' ) );
  buffer = luaDeleteComments( buffer );
  if data['names'] == True:
    buffer = luaMinNames( buffer );
    log( 'luamin', 'info', 'After names min: ' + str( len( buffer ) ) + ' byte' );
  buffer = luaConvertTabsToSpaces( buffer );
  if data['newLine'] == True:
    buffer = luaMinNewLines( buffer );
  if data['spaces'] == True:
    buffer = luaMinSpaces( buffer );
    log( 'luamin', 'info', 'After spaces min: ' + str( len( buffer ) ) + ' byte' );
  log( 'luamin', 'info', 'Reducing the size from: ' + str( startSize ) + ' byte to ' + str( len( buffer ) ) + ' byte (' + str( int( len( buffer ) * 100 / startSize ) ) + '%)' );  
  name = os.path.join( data['out'], makeFileName( data['script'], 'min', 'lua' ) );
  f    = open( name, 'w' );
  f.write( buffer );
  f.close();
  return name;
#----------------------------------------------------------------------------------------
def getExceptions ():
  out = [];
  f = open( os.path.join( os.path.dirname(os.path.abspath(__file__)), 'exceptionsNames.json' ), 'r' );
  data = json.loads( f.read() );
  for record in data['exceptions']:
    reservedNames.append( record )
  return;  
#----------------------------------------------------------------------------------------
def minlua ( args ):
  getExceptions();
  data  = analizInput( args );
  error = checkInputData( data );
  flags = '';
  if data['newLine']:
    flags += 'newLine ';
  if data['spaces']:
    flags += 'spaces ';
  if data['names']:
    flags += 'names ';  
  log( 'luamin', 'info', ( 'Run with flags: ' + flags ) );
  if ( error == None ):
    runCommand( data );
  else:
    log( 'luamin', 'error', error );   
  return;
#----------------------------------------------------------------------------------------
minlua( sys.argv );