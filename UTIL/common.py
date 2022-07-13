import sys
import os

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