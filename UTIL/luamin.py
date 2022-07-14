#!/usr/bin/python
from re import L
import sys
import os
import itertools
from luaparser import ast
from luaparser import astnodes
from common import getExtension, checkFile
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

reservedNames = [ 'setmetatable', 'stop', 'self' ];

unaryPriority = 8;


#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
def analizInput ( args ):
  data = {
    "command"       : '',
    "file"          : '',
    "newLine"       : False,
    "spaces"        : False,
    "varNames"      : False,
    "functionNames" : False
  }
  for i in range( len( args ) ):
    if args[i] == '-h':
      data['command'] = '-h';
    if ( args[i] == '-s' ) and ( len( args ) > ( i + 1 ) ):
      data['script'] = args[i + 1];
    if ( args[i] == '-a' ):
      data['newLine']       = True;
      data['spaces']        = True;
      data['varNames']      = True;
      data['functionNames'] = True;
    if ( args[i] == '-n' ):
      data['newLine']       = True;
    if ( args[i] == '-sp' ):
      data['spaces']        = True;
    if ( args[i] == '-v' ):
      data['varNames']      = True;  
    if ( args[i] == '-f' ):  
      data['functionNames'] = True;
  return data;

def checkInputData ( data ):
  error = None;
  if ( data['command'] != '' ) or ( data['command'] != '-h' ):
    error = 'Wrong command';
  error = checkFile( data['script'], '.lua' );
  return error;

def runCommand ( data ):
  if ( data['command'] == '' ):
    luaMinProcessing( data );
  else:
    if ( data['command'] == '-h' ):
      showHelp();
  return;

def showHelp ():
  print( '*************************************************' );
  print( '    -h:  get help information'                     );
  print( '    -s:  set script file'                          );
  print( '    -a:  optimise all scenarios'                   );
  print( '    -n:  optimise new line symbols'                );
  print( '    -sp: optimise spaces symbols'                  );
  print( '    -v:  optimise variables names'                 );
  print( '    -f:  optimise functions names'                 );
  print( '*************************************************' );
  return;  
#----------------------------------------------------------------------------------------
def luaOpenScript ( path ):
  f = open( path, 'r', encoding='utf-8' );
  buffer = f.read();
  f.close();
  return buffer;
#----------------------------------------------------------------------------------------

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

def luaMinFunctionNames ( data ):
  out = data;
  return out;

def getVarName ( name, varList, static ):
  if name not in reservedNames: 
    index = -1;
    for i in range( len( varList ) ):
      if varList[i][0] == name:
        index = i;
        break;
    if index == -1:
      varList.append( [name, static] );
      index = len( varList ) - 1;
    name = makeNewMinName( index );
  return name;

def cleanVarList ( varList ):
  out = [];
  for var in varList:
    if var[1] == True:
      out.append( var );
  return out;    

def processLuaAssign ( assign, varList ):
  for node in ast.walk( assign ):
    if isinstance( node, astnodes.Name ):
      node.id = getVarName( node.id, varList, False );
  return;  

def processLuaFunction ( function, varList ):
  out = function;
  for node in ast.walk( out ):
    if isinstance( node, astnodes.Function ):
      node.name.id = getVarName( node.name.id, varList, True );
      for arg in node.args:
        arg.id = getVarName( arg.id, varList, False );
    elif isinstance( node, astnodes.Assign ):
      processLuaAssign( node, varList );   
    elif isinstance( node, astnodes.Call ):
      node.func.id = getVarName( node.func.id, varList, True );
      for arg in node.args:
        if isinstance( arg, astnodes.Index ):
          arg.idx.id = getVarName( arg.idx.id, varList, False );
        if isinstance( arg, astnodes.Name ):
          arg.id = getVarName( arg.id, varList, False );
    elif isinstance( node, astnodes.Return ):
      for value in node.values:
        if ( "id" in dir( value ) ):
          value.id = getVarName( value.id, varList, False );
    elif isinstance( node, astnodes.If ) or isinstance( node, astnodes.ElseIf ) or isinstance( node, astnodes.While ):
      for state in ast.walk( node.test.left ):
        if isinstance( state, astnodes.Name ):
          state.id = getVarName( state.id, varList, False );
      for state in ast.walk( node.test.right ):
        if isinstance( state, astnodes.Name ):
          state.id = getVarName( state.id, varList, False );
    elif isinstance(node, astnodes.Fornum ):
      if isinstance( node.target, astnodes.Name ):
        node.target.id = getVarName( node.target.id, varList, False );
      if isinstance( node.start, astnodes.Name ):  
        node.start.id = getVarName( node.start.id, varList, False );
      if isinstance( node.stop, astnodes.Name ):  
        node.stop.id = getVarName( node.stop.id, varList, False );
      if isinstance( node.step, astnodes.Name ):
        node.step.id = getVarName( node.step.id, varList, False );
      
  return out;

def luaMinVarNames ( data ):
  out     = data;
  tree    = ast.parse( out );
  varList = [];

  for node in tree.body.to_json()['Block']['body']:
    if isinstance( node, astnodes.Function ):
      node    = processLuaFunction( node, varList );
      varList = cleanVarList( varList );  
    elif isinstance( node, astnodes.Assign ):
      for value in node.values:
        if isinstance( value, astnodes.Name ):
          value.id = getVarName( value.id, varList, True );
      for target in node.targets:
        if isinstance( target, astnodes.Index ):
          target.value.id = getVarName( target.value.id, varList, True );
        if isinstance( target, astnodes.Name ):
          target.id = getVarName( target.id, varList, True );
    elif isinstance( node, astnodes.Method ):
      node.source.id = getVarName( node.source.id, varList, True );
      node.name.id   = getVarName( node.name.id, varList, True );
      for arg in node.args:
        arg.id = getVarName( arg.id, varList, False );
      node    = processLuaFunction( node, varList );
      varList = cleanVarList( varList );    
      
  
  out = ast.to_lua_source( tree );
  print( out )
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

def luaMinProcessing( data ):
  buffer = luaOpenScript( data['script'] );
  #buffer = luaDeleteComments( buffer );
  #buffer = luaConvertTabsToSpaces( buffer );
  #if data['functionNames'] == True:
  #  buffer = luaMinFunctionNames( buffer );
  if data['varNames'] == True:
    buffer = luaMinVarNames( buffer );
  #if data['spaces'] == True:
  #  buffer = luaMinSpaces( buffer );
  #if data['newLine'] == True:
  #  buffer = luaMinNewLines( buffer );
  return;
#----------------------------------------------------------------------------------------
def minlua ( args ):
  data  = analizInput( args );
  error = checkInputData( data );
  if ( error == None ):
    runCommand( data );
  return;
#----------------------------------------------------------------------------------------
minlua( sys.argv );