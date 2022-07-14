#!/usr/bin/python
import sys
import os
import json
from common import getExtension, checkFile
#----------------------------------------------------------------------------------------
def getIncludeList ( ldpath ):
  error = None;
  list = [];
  try:
    f    = open( ldpath, 'r' );
    data = json.loads( f.read() )
  except:
    error = "[lualink] Wrong lib file encoding: " + ldpath;  
  if error == None:
    if 'include' in data.keys():
      list = data['include'];
    else:
      error = "[lualink] Wrong ld file format"
  return [list, error];

def getLibContent ( path ):
  out   = '';
  error = checkFile( path, '.lua' );
  if error == None:
    f   = open( path, 'r', encoding='utf-8' );
    out = f.read();
  return [out,error];

def addIncludesToScript ( path, includes, output ):
  error  = None;
  out    = '';
  try:
    f      = open( path, 'r', encoding='utf-8' );
    buffer = f.read().replace( '#!/usr/local/bin/lua\n', '' );
    f.close();
  except:
    error = "[lualink] Wrong script file encoding";
  if ( error == None ):    
    for include in includes:
      out = out + '----------------------------------------------------------------------------------------------------------------------\n';
      out = out + include + '\n';
    out = out + buffer;
    print( os.path.join( output, os.path.basename( path ) ) )
    f   = open( os.path.join( output, os.path.basename( path ) ), 'w' );
    f.write( out );
    f.close();
  return error;
#----------------------------------------------------------------------------------------
def analizInput ( args ):
  data = {
    "command" : '',
    "script"  : '',
    "ld"      : '',
    "out"     : ''
  }
  for i in range( len( args ) ):
    if args[i] == '-h':
      data['command'] = '-h';
    if ( args[i] == '-s' ) and ( len( args ) > ( i + 1 ) ):
      data['script'] = args[i + 1];
    if ( args[i] == '-l' ) and ( len( args ) > ( i + 1 ) ):
      data['ld'] = args[i + 1];
    if ( args[i] == '-o' ) and ( len( args ) > ( i + 1 ) ):
      data['out'] = args[i + 1];
  return data;

def checkInputData ( data ):
  error    = None;
  if ( data['command'] != '' ) or ( data['command'] != '-h' ):
    error = '[lualink] Wrong command';
  error = checkFile( data['script'], '.lua' );
  if error == None:
    if ( data['ld'] == '' ):
      data['ld'] = 'luald.json';
    error = checkFile( data['ld'], '.json' );
    if error == None:
      if ( data['out'] == '' ):
        data['out'] = os.path.join( os.getcwd(), 'out' );
      if not os.path.exists( data['out'] ):
        os.mkdir( data['out'] );  
  return error;
#----------------------------------------------------------------------------------------
def showHelp ():
  print( '*************************************************' );
  print( '    -h: get help information'                      );
  print( '    -s: set script file'                           );
  print( '    -l: set ld file in json format'                );
  print( '    -o: set output path'                           );
  print( '*************************************************' );
  return;

def luaLink ( script, ld, out ):
  includes = [];
  [paths, error] = getIncludeList( ld );
  if ( error == None ):
    for path in paths:
      [data,error] = getLibContent( path );
      if ( error != None ):
        print( error + ' in ' + path );
        return;
      includes.append( data );
    error = addIncludesToScript( script, includes, out )
    if ( error != None ):
      print( error );
    else:
      print( "[lualink] Done" )  
  else:
    print( error );
  return;
#----------------------------------------------------------------------------------------
def runCommand ( data ):
  if ( data['command'] == '' ):
    if ( data['script'] != '' ) and ( data['ld'] != '' ):
      luaLink( data['script'], data['ld'], data['out'] );
    else:
      print( "[lualink] There isn't full data for the linker" );  
  else:
    if ( data['command'] == '-h' ):
      showHelp();
  return;
#----------------------------------------------------------------------------------------
def lualink ( args ):
  data  = analizInput( args );
  error = checkInputData( data );
  if ( error == None ):
    runCommand( data );
  return;  
#----------------------------------------------------------------------------------------
lualink( sys.argv );