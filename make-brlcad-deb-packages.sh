#!/bin/sh
#                     M A K E _ D E B . S H
#           (original and current BRL-CAD source name)
# BRL-CAD
#
# Copyright (c) 2005-2013 United States Government as represented by
# the U.S. Army Research Laboratory.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided
# with the distribution.
#
# 3. The name of the author may not be used to endorse or promote
# products derived from this software without specific prior written
# permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
###

# This file name: make-brlcad-deb-packages.sh
#
# This file was copied from BRL-CAD sh/make_deb.sh in April 2013 to
# start the out-of-tree semi-official BRL-CAD Debian package project.
# The goal of this project is to become the official Debian BRL-CAD package source.
#
# The original package maintainer for this project is Tom Browder
# <tom.browder@gmail.com> who introduced himself to the current Debian
# BRL-CAD package maintainer, Giuseppe Iuculano
# <giuseppe@iuculano.it>.  The current Debian project is inactive and
# has not been tended since 2009.  Tom also presented himself to the
# Debian maintainers group to whom the package belongs
# (science-maintainers) and stated his intentions to co-maintain the
# package and get a Debian Maintainer to sign his public key.
#
# The original file has been modified to (1) satisfy Debain packaging
# policy, (2) work with a cmake configuration and build outside the
# BRL-CAD source tree, and (3) respect the desires of the BRL-CAD
# developers when they do not conflict with Debian policy.

set -e

# NOTE: This script is designed to be run in a subdir of a Makefile
#       driving it.

# file to be sourced
SFIL=brlcad-version.sh

ferror(){
    echo "=========================================================="
    echo $1
    echo $2
    echo "=========================================================="
    exit 1
}

# show help
if test -z $1 ;then
    echo "Script to create Debian binary and source packages."
    echo
    echo "Usage:"
    echo "  $0 -b | -s [-t]"
    echo
    echo "Options:"
    echo "  -b       build the Debian binary package (deb file)"
    echo "  -s *     build the Debian source packages"
    echo "  -t       as second argument: test for all prerequisites"
    echo
    echo "           * (use with a clean brlcad tree)"
    echo
    echo "You MUST provide a separate file to be sourced, '$SFIL',"
    echo "  defining two variables:"
    echo
    echo "  BVERSION - the BRL-CAD version to use, e.g, '7.23.1'"
    echo "             (without the quotes)"
    echo "  SRCDIR   - the pristine BRL-CAD source directory"
    echo
    exit 1
fi

# too many parameters
if test $# -gt 2 ;then
    ferror "Too many arguments" "Exiting..."
fi

# unknown parameter
if test "$1" != "-s" && test "$1" != "-b" ; then
    ferror "Unknown first argument '$1'." "Exiting..."
fi

# check for test
TEST=0
if test $# -eq 2 && test "$2" != "-t" ; then
    ferror "Unknown second argument '$2'." "Exiting..."
elif test $# -eq 2 && test "$2" = "-t" ; then
   TEST=1
fi

# test if in build directory
if test ! -f debian/control ; then
    ferror "'$0' should be run from project build directory." "Exiting..."
fi

# test if in debian-like system
if test ! -e /etc/debian_version ; then
    ferror "Refusing to build on a non-debian system." "Exiting..."
fi

# test for version source file
if test ! -e "../$SFIL" ; then
    ferror "Unable to find file '$SFIL'." "Exiting..."
fi

# source it to get BVERSION and SRCDIR
echo "In dir `pwd`..."
echo "Sourcing '../$SFIL"
# note /bin/sh does not recognize cmd 'source'
. "../$SFIL"

# check needed packages
E=0
fcheck() {
    T="install ok installed"
    if test ! `dpkg -s $1 2>/dev/null | grep "$T" | wc -l` -eq 0 ; then
	# success
	echo "Found package $1..."
	return
    fi

    # need to check for local, non-package versions
    # check for binaries
    if test "$2" = "x" ; then
	if [ -f /usr/bin/$1 ]; then
	    # success
	    echo "Found /usr/bin/$1..."
	    return
	elif [ -f /usr/local/bin/$1 ]; then
	    # success
	    echo "Found /usr/local/bin/$1..."
	    return
	fi
    fi

    echo "* Missing $1..."
    LLIST=$LLIST" "$1
    E=1
}

fcheck debhelper
fcheck fakeroot x

if test "$1" = "-b" ;then
    fcheck build-essential
    fcheck make
    fcheck cmake x
    fcheck sed x
    fcheck bison x
    fcheck flex x
    fcheck libxi-dev
    fcheck xsltproc x
    fcheck libglu1-mesa-dev
    fcheck libpango1.0-dev
    fcheck fop # allows pdf creation
fi

if [ $E -eq 1 ]; then
    ferror "Mandatory to install these packages first:" "$LLIST"
fi

# set variables
CDATE=`date -R`
CFILE="debian/changelog"
RELEASE="0"

NJOBS=`getconf _NPROCESSORS_ONLN`
if test ! $NJOBS -gt 0 2>/dev/null ;then
    NJOBS=1
fi

# if building sources, create *orig.tar.gz
# TB: DON'T delete
#rm -Rf debian
if test "$1" = "-s" ;then
    echo "building brlcad_$BVERSION.orig.tar.gz..."
    tar -czf "../brlcad_$BVERSION.orig.tar.gz" "../$SRCDIR/*"
fi

# create "version" file
echo $BVERSION >debian/version

# update debian/changelog if needed
L1="brlcad ($BVERSION-$RELEASE) unstable; urgency=low\n\n"
L2="  **** VERSION ENTRY AUTOMATICALLY ADDED BY \"make-brlcad-deb-packages.sh\" SCRIPT ****\n\n"
L3=" -- $PACKAGER  $CDATE\n\n/"

if test -s $CFILE ; then
  # file exists with size > 0
  if  test `sed -n '1p' $CFILE | grep "brlcad ($BVERSION-$RELEASE" | wc -l` -eq 0 ; then
    sed -i "1s/^/$L1$L2$L3" $CFILE
    echo "\"$CFILE\" has been modified!"
  else
    echo "\"$CFILE\" has NOT been modified!"
  fi
else
    # [re]create an empty file with one line so the expression will work
    echo > $CFILE
    sed -i "1s/^/$L1$L2$L3" $CFILE
    echo "\"$CFILE\" has been modified!"
fi

if [ $TEST -eq 1 ]; then
    echo "=========================================================="
    echo "Testing complete"
    echo "Ready to create a Debian package"
    echo "=========================================================="
    exit
fi

# create deb or source packages
case "$1" in
-b) fakeroot debian/rules clean
    DEB_BUILD_OPTIONS=parallel=$NJOBS fakeroot debian/rules binary
    ;;
-s) fakeroot dpkg-buildpackage -S -us -uc
    ;;
esac

# Local Variables:
# mode: sh
# tab-width: 8
# sh-indentation: 4
# sh-basic-offset: 4
# indent-tabs-mode: t
# End:
# ex: shiftwidth=4 tabstop=8
