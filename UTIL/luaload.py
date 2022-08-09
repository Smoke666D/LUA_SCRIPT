import sys
import serial
import time
from common import checkFile, log, progressBar
#----------------------------------------------------------------------------------------
ser = serial.Serial();
timeout = 10;
#----------------------------------------------------------------------------------------
def serialInit ( port ):
  ser.port     = port;
  ser.baudrate = 115200;
  ser.open();
  return ser.is_open;

def serialReadResponse ():
  counter = 0;
  line    = '';
  while ( ( line == '' ) and ( counter < timeout ) ):
    counter += 1;
    line = ser.readline();
    time.sleep( 0.1 );
  return line;  

def serialStartWriting ():
  ser.write( b'set flash\n' );
  return serialReadResponse() == b'Ok\n';

def serialWriteLua ( script ):
  res = True;
  f = open( script, 'r', encoding='utf-8' );
  data = f.read()
  for i in range( len( data ) ):
    ser.write( b'set script ' + str( ord( data[i] ) ).encode('ascii') + b'\n' );
    if serialReadResponse() != b'Ok\n':
      res = False;
      break;
    progressBar( i, ( len( data ) - 1 ) );
  return res;

def serialFinishWriting ():
  ser.write( b'reset flash\n' );
  return serialReadResponse() == b'Ok\n';
#----------------------------------------------------------------------------------------
def analizInput ( args ):
  data = {
    "command" : '',
    "script"  : '',
    "port"    : ''
  }
  for i in range( len( args ) ):
    if args[i] == '-h':
      data['command'] = '-h';
    if ( args[i] == '-s' ) and ( len( args ) > ( i + 1 ) ):
      data['script'] = args[i + 1];
    if ( args[i] == '-p' ) and ( len( args ) > ( i + 1 ) ):
      data['port'] = args[i + 1];
  return data;

def checkInputData ( data ):
  error = None;
  if ( data['command'] != '' ) and ( data['command'] != '-h' ):
    error = 'Wrong command';
  if error == None:
    if data['command'] != '-h':
      error = checkFile( data['script'], '.lua' );
      if error == None:
        if data['port'] == '':
          error = 'There is no port'
  return error;

def runCommand ( data ):
  if ( data['command'] == '' ):
    if serialInit( data['port'] ) == True:
      log( 'luaload', 'info', ( data['port'] + ' opened') );
      if serialStartWriting() == True:
        log( 'luaload', 'info', 'Flash unlocked' );
        if serialWriteLua( data['script'] ) == True:
          log( 'luaload', 'info', 'Script loaded' );
          if serialFinishWriting() == True:
            log( 'luaload', 'info', 'Flash locked' );
            log( 'luaload', 'info', 'Done!' );
          else:
            log( 'luaload', 'error', 'Flash locking error' );
        else:
          log( 'luaload', 'error', 'Flash writing error' );
      else:
        log( 'luaload', 'error', 'Flash unlocking error' );
      ser.close();
    else:
      log( 'luaload', 'error', 'Port openning error' );    
  else:
    if ( data['command'] == '-h' ):
      showHelp();
  return;

def showHelp ():
  print( '*************************************************' );
  print( '    -h:  get help information'                     );
  print( '    -s:  set script file'                          );
  print( '    -p:  serial port'                              );
  print( '*************************************************' );
  return;  
#----------------------------------------------------------------------------------------
def luaload ( args ):
  data  = analizInput( args );
  error = checkInputData( data );
  if ( error == None ):
    runCommand( data );
  else:
    log( 'luaload', 'error', error );
  return;
#----------------------------------------------------------------------------------------
luaload( sys.argv );