#!/bin/sh

#  upload-symbols.sh
#  Created by Greg Whatley on 1/11/19.
#
#  This script uploads dSYMs to Firebase for processing.
#  Usage: Find the archive to upload dSYMs from and click "Download Debug Symbols" from Xcode Organizer.  Drag script into terminal then drag archive file (~/Library/Developer/Xcode/Archives) into terminal after script.  Press return.

ARCHIVE=$1
if [ -f $ARCHIVE ]; then
    find "$ARCHIVE/dSYMs" -name "*.dSYM" | xargs -I \{\} /Users/devgregw/Desktop/GitHub/AuthenticiOS/Pods/Fabric/upload-symbols -gsp /Users/devgregw/Desktop/GitHub/AuthenticiOS/AuthenticiOS/GoogleService-Info.plist -p ios \{\}
    echo "Upload complete!"
else
    echo "Archive does not exist!"
fi
