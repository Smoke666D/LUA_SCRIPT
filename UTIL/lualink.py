#!/usr/bin/python
import sys
import os
import json
#----------------------------------------------------------------------------------------
def getIncludeList ( ldpath ):
  error = None;
  list = [];
  f    = open( ldpath, 'r' );
  data = json.loads( f.read() )

  if 'include' in data.keys():
    list = data['include'];
  else:
    error = "Wrong ld file format"
  return [list, error];

def getLibContent ( path ):
  out   = '';
  error = checkFile( path, '.lua' );
  if error == None:
    f   = open( path, 'r', encoding='utf-8' );
    out = f.read();
  return [out,error];

def addIncludesToScript ( path, includes, output ):
  out    = '#!/usr/local/bin/lua\n';
  f      = open( path, 'r', encoding='utf-8' );
  buffer = f.read().replace( '#!/usr/local/bin/lua\n', '' );
  f.close();
  for include in includes:
    out = out + '----------------------------------------------------------------------------------------------------------------------\n';
    out = out + include + '\n';
  out = out + buffer;
  print( os.path.join( output, os.path.basename( path ) ) )
  f   = open( os.path.join( output, os.path.basename( path ) ), 'w' );
  f.write( out );
  f.close();
  return;  
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

def getExtension ( path ):
  return os.path.splitext( path )[1];

def checkFile ( path, extension ):  
  error    = None;
  if ( path != '' ):
    if not os.path.isabs( path ):
      path = os.path.join( os.getcwd(), path );
    if not os.path.isfile( path ):
      return "File is not a exist";
    if ( getExtension( path ) != extension ):
      return "Wrong file format";
  return error;    

def checkInputData ( data ):
  error    = None;
  if ( data['command'] != '' ) or ( data['command'] != '-h' ):
    error = 'Wrong command';
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
    addIncludesToScript( script, includes, out )
  else:
    print( error );
  return;
#----------------------------------------------------------------------------------------
def runCommand ( data ):
  if ( data['command'] == '' ):
    if ( data['script'] != '' ) and ( data['ld'] != '' ):
      luaLink( data['script'], data['ld'], data['out'] );
    else:
      print( "There isn't full data for the linker" );  
  else:
    if ( data['command'] == '-h' ):
      showHelp();
  return;
#----------------------------------------------------------------------------------------
data  = analizInput( sys.argv );
error = checkInputData( data );
if ( error == None ):
  runCommand( data );