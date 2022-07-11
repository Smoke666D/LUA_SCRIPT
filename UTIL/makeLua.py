#!/usr/bin/python
import sys
import os
#----------------------------------------------------------------------------------------
minmizeSymbols = { '=', '{', '}', '(', ')', ',', '+', '-', '*', '/', '&', '|', '~', '<', '>', '\\n' };
#----------------------------------------------------------------------------------------
def noCallback ( data, error ):
  if ( error != None ):
    print( error );  
  return;
#----------------------------------------------------------------------------------------
def analizInput ( callback = noCallback ):
  errorStr = None;
  data = {
    'command':   '-h',
    'inputFile': '',
    'outputPath': ''
  };
  if ( len( sys.argv ) > 1 ):
    data['command'] = sys.argv[1];
    if ( len( sys.argv ) > 2 ):
      data['inputFile'] = sys.argv[2];
      if ( len( sys.argv ) > 3 ):
        data['outputPath'] = sys.argv[3];
  else:
    errorStr = 'No command';
  callback( data, errorStr );
  return [data, errorStr];
#----------------------------------------------------------------------------------------
def showHelp ():
  print( '*************************************************' );
  print( '    -h: get help information'                      );
  print( '    -m: make lua script. 1st argument - input'     );
  print( '        file of lua, 2nd argument - output path'   );
  print( '*************************************************' );
  return;
#----------------------------------------------------------------------------------------
def getOutputPath ( path = '' ):
  outputPath = '';
  if len( path ) == 0:
    outputPath = os.path.dirname( __file__ );
    outputPath = os.path.join( outputPath, 'out' );
  else:
    outputPath = path;
  if not os.path.exists( outputPath ):
    os.mkdir( outputPath );
  return outputPath;
#----------------------------------------------------------------------------------------
def delateSpaces ( data, char ):
  out = data
  out = out.replace( ( ' ' + char ), char );
  out = out.replace( ( char + ' ' ), char );
  return out;
#----------------------------------------------------------------------------------------
def minimiseLua ( data ):
  out = data;
  out = out.replace( '\n', ' ' );
  out = out.replace( '\"', '\\"' );  
  out = out.replace( '\t', ' ' );
  while ( out.find( '  ' ) != -1 ):
    out = out.replace( '  ', ' ' );  
  for symbol in minmizeSymbols:
    out = delateSpaces( out, symbol );
  return out;
#----------------------------------------------------------------------------------------
def makeCfile ( data, path ):
  hfile  = os.path.basename( path ).replace( '.c', '.h' );
  string = minimiseLua( data );
  f = open( path, 'w' );
  f.write( '#include "' + hfile + '"\n' );
  f.write( 'const char* const defaultLuaScript = "' + string + '";\n' );
  f.close();
  return;
#----------------------------------------------------------------------------------------
def makeHfile ( data, path ):
  name   = os.path.basename( path ).replace( '.', '_' ).upper();
  f = open( path, 'w' );
  f.write( '#ifndef ' + name + '\n' );
  f.write( '#define ' + name + '\n\n');
  f.write( 'extern const char* const defaultLuaScript;\n')
  f.write( '\n#endif' + '\n');
  f.close();
  return;  
#----------------------------------------------------------------------------------------
def getLuaScript ( path = '', callback = noCallback ):
  errorStr = None;
  luaPath  = '';
  data     = '';
  if ( len( path ) == 0 ):
    luaPath = os.path.dirname( os.path.dirname( __file__ ) );
    luaPath = os.path.join( luaPath, 'TEST.lua' );
  else:
    luaPath = path;
  if ( luaPath.endswith( '.lua' ) == True ):    
    if ( os.path.exists( luaPath ) == False ):
      errorStr = "There is no file on: " + luaPath;  
    else:
      f    = open( luaPath, 'r' );
      data = f.read();
  else:
    errorStr = "This isn't lua file";
  callback( data, errorStr );  
  return [data, errorStr];
#----------------------------------------------------------------------------------------
def parsingCommand ( data, error ):
  errorStr = None;
  if ( error == None ):
    if ( data['command'] == '-h' ):
      showHelp();
    elif ( data['command'] == '-m' ):
      [lua, err] = getLuaScript( data['inputFile'] );
      if ( err == None ):
        outputPath = getOutputPath( data['outputPath'] );
        cPath      = os.path.join( outputPath, 'luaDefScript.c' );
        hPath      = os.path.join( outputPath, 'luaDefScript.h' );
        makeCfile( lua, cPath );
        makeHfile( lua, hPath );
        print( 'Ready!' );
      else:
        print( err );  
    else:    
      errorStr = 'Wrong command';  
      print( errorStr );
  else:
    print( error );    
  return;
#----------------------------------------------------------------------------------------

print( "---" )
analizInput( parsingCommand );
print( "---" )