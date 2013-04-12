# need to completely clean up after a Debian build

# important: set BRL-CAD version here
#BVERSION = 7.22.0
BVERSION = 7.23.1

# set HEAD to the the upstream source VCS source dir; comment it out
# if not needed
HEAD=/usr/local/src2/brlcad-svn/brlcad/trunk

SHELL   = /bin/bash
SRCDIR  = brlcad-$(BVERSION)
PKG     = brlcad-$(BVERSION).tar.bz2
BLDDIR  = brlcad-build

TOPDIR := $(shell pwd)

DEB_SCRIPT  = make-brlcad-deb-packages.sh

BLD_ARGS  = rel
#BLD_ARGS = deb
#BLD_ARGS += pdf

# set configure options
include Makefile.brlcad-options

# define dirs in the build directory that may be cleaned
include Makefile.build-files

all:
ifneq ($(strip $(HEAD)),)
	@echo "Testing with updated HEAD"
endif
	@echo "Set for BRL-CAD version '$(BVERSION)'."
	@echo " "
	@echo "Enter 'make clean' to remove build files in"
	@echo "  '$(BLDDIR)'."
	@echo " "
	@echo "Enter 'make conf' to remove build files in"
	@echo "  '$(BLDDIR)' and reconfigure the directory."
	@echo " "
	@echo "Enter 'make check' to check for pre-requisites."
	@echo " "
	@echo "Enter 'make deb' to build the deb packages."

deb:
	@echo "Building Debian packages..."
	( cd $(BLDDIR); $(TOPDIR)/$(DEB_SCRIPT) -b | tee build.log )

check:
	@echo "Checking for pre-requisites..."
	( cd $(BLDDIR); $(TOPDIR)/$(DEB_SCRIPT) -b -t )

clean:
	@echo "Removing all but the 'debian' dir in directory '$(BLDDIR)'..."
	( cd $(BLDDIR); rm $(BUILD_FILES); rm -rf $(BUILD_DIRS) )
	@echo "See 'debian' dir in directory '$(BLDDIR)'..."

update:
ifneq ($(strip $(HEAD)),)
	@echo "Updating HEAD..."
	@echo "Changing to dir '$(HEAD)'..."
	( cd $(HEAD) ; svn update )
	echo "Done..."
else
	@echo "Not using HEAD, update not needed..."
endif

conf: clean update

	@echo "Copying some extra files to directory '$(BLDDIR)'..."
	(cd $(SRCDIR) ; cp $(FILES_TOP) $(TOPDIR)/$(BLDDIR) )
	mkdir -p $(BLDDIR)/include/conf
	(cd $(SRCDIR)/include/conf ; cp $(FILES_CONF) $(TOPDIR)/$(BLDDIR)/include/conf )
	@echo "Reconfiguring directory '$(BLDDIR)'..."
	( unset BRLCAD_ROOT ; cd $(BLDDIR) ; cmake $(TOPDIR)/$(SRCDIR) $(RELEASE_OPTIONS) )
