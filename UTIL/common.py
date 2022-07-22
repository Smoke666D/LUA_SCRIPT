import sys
import os
from datetime import datetime

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def log ( source, type, text ):
  output = bcolors.OKBLUE + str( datetime.now() ) + ' ';

  output += bcolors.HEADER + '<<'+ source + '>> ';

  if type == 'error':
    output += bcolors.FAIL + '[ERROR] ';
  elif type == 'warning':
    output += bcolors.WARNING + '[WARNING] ';
  else:
    output += bcolors.OKGREEN + '[MESSAGE] ';

  output += bcolors.OKCYAN + text;

  output += bcolors.ENDC;  
  print(  output );

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

def makeFileName ( base, add, ext ):
  name = os.path.basename( base );
  name = name[0:name.find( '.' )];
  name = name + '.' + add + '.' + ext;  
  return name

def progressBar ( progress, total ):
  persent = 100 * ( progress / float( total ) );
  bar     = '█' * int( persent ) + '▒' * ( 100 - int( persent ) );
  print( bcolors.WARNING + f"\r{bar} {persent:.2f}%", end="\r" );
  if ( progress == total ):
    print( bcolors.OKGREEN + f"\r{bar} {persent:.2f}%", end="\r" );
    print( '\n' );
  return;