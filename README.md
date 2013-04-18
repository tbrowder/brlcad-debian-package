brlcad-debian-package
=====================

Debian package for BRL-CAD

This "sand box" is designed to keep all necessary files for BRL-CAD
Debian package making under version control.  The only direct upstream
source is the selected release source tar ball which is unpacked into
a pristine directory in this directory and it is not intended to be
touched by the packaging process.  Any necessary source code changes
are kept with the Debian 'quilt' utility whose database will also be
kept under version control.  Such changes will also be fed upstream.

The package is built out-of-tree in the 'build-tmp' directory, and the
Makefiles are used to drive the process from this top-level directory.  All
files BUT the 'debian' directory can be deleted without harm since
they are part of the 'cmake' configuration process.

The 'debian' directory is kept under version control and generally
stays synchronized with its sister directory in the upstream BRL-CAD
HEAD.  Necessary changes to satisfy the latest Debian policy and
Debian Maintainers are fed back upstream.

Building packages
=================

* Select and copy an original upstream tar ball of the desired release
  into this directory.

* Unpack the tar ball and leave it in place.

* Edit 'Makefile' to define the correct release version.

Execute 'make' in this directory to see further instructions.

Packages
========

The following binary packages are planned:

* brlcad
* brlcad-dev
* brlcad-utils
* brlcad-doc
* brlcad-dbg
