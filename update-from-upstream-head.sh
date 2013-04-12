#!/bin/bash

# this is a convenience script to ease building from the latest
# upstream HEAD during testing; note I soft link HEAD to
# './brlcad-N.NN.N' in this directory where 'N.NN.N' is named after
# the current unstable or HEAD pseudo release tag

HEAD=/usr/local/src2/brlcad-svn/brlcad/trunk

echo "Updating '$HEAD'..."
(cd $HEAD ; echo "  Changing to dir '`pwd`" ; svn update )
echo "Done..."
