#!/usr/bin/python
import sys
import os
from common import log, checkFile
#----------------------------------------------------------------------------------------
def analizInput ( args ):
  errorStr = None;
  data = {
    'command' : '',
    'script'  : '',
    'out'     : ''
  };
  for i in range( len( args ) ):
    if args[i] == '-h':
      data['command'] = '-h';
    if ( args[i] == '-s' ) and ( len( args ) > ( i + 1 ) ):
      data['script'] = args[i + 1];
    if ( args[i] == '-o' ) and ( len( args ) > ( i + 1 ) ):
      data['out'] = args[i + 1];
  return data;
#----------------------------------------------------------------------------------------
def checkInputData ( data ):
  error    = None;
  if ( data['command'] != '' ) or ( data['command'] != '-h' ):
    error = 'Wrong command';
  error = checkFile( data['script'], '.lua' );
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
  print( '    -o: set output path'                           );
  print( '*************************************************' );
  return;
#----------------------------------------------------------------------------------------
def makeCfile ( data, path ):
  data  = data.replace( '\"', '\\"' );  
  hfile = os.path.basename( path ).replace( '.c', '.h' );
  f = open( path, 'w', encoding='utf-8' );
  f.write( '#include "' + hfile + '"\n' );
  f.write( 'const char* const defaultLuaScript = "' + data + '";\n' );
  f.close();
  return;
#----------------------------------------------------------------------------------------
def makeHfile ( data, path ):
  name   = os.path.basename( path ).replace( '.', '_' ).upper();
  f = open( path, 'w', encoding='utf-8' );
  f.write( '#ifndef ' + name + '\n' );
  f.write( '#define ' + name + '\n\n');
  f.write( 'extern const char* const defaultLuaScript;\n')
  f.write( '\n#endif' + '\n');
  f.close();
  return;  
#----------------------------------------------------------------------------------------
def runCommand ( data ):
  if ( data['command'] == '' ):
    f   = open( data['script'], 'r', encoding='utf-8' );
    lua = f.read();
    f.close();
    makeCfile( lua, os.path.join( data['out'], 'luaDefScript.c' ) );
    makeHfile( lua, os.path.join( data['out'], 'luaDefScript.h' ) );
    log( 'luamake', 'info', 'Done' );
  else:  
    if ( data['command'] == '-h' ):
      showHelp();
  return;
#----------------------------------------------------------------------------------------
def luamake ( args ):
  data  = analizInput( args );
  error = checkInputData( data )
  if ( error == None ):
    runCommand( data )
  else:
    log( 'luamake','error', error );  
  return;
#----------------------------------------------------------------------------------------
luamake( sys.argv );