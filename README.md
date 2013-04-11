brlcad-debian-package
=====================

Debian package for BRL-CAD

This "sand box" is designed to keep all necessary files for BRL-CAD
Debian package making under version control.  The only direct upstream
source is the released source tar ball which is unpacked into a
pristine directory and is not intended to be touched by the packaging
process.

The package is build out-of-tree in the 'brlcad-build' directory and
the Makefiles and a package building script
(make-brlcad-deb-packages.sh) are used to drive the process from this
top-level directory.  All files BUT the 'debian' directory can be
deleted without harm since they are part of the 'cmake' configuration
process.

The 'brlcad-build/debian' directory is kept under version control and
generally stays synchronized with its sister directory in the upstream
BRL-CAD HEAD.  Necessary changes to satisfy the latest Debian policy
and Debian Maintainers are fed back upstream.


