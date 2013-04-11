# need to completely clean up after a Debian build

# important: set BRL-CAD vesion here
BVERSION = 7.22.0

SHELL   = /bin/bash
SRCDIR  = brlcad-$(BVERSION)
PKG     = brlcad-$(BVERSION).tar.bz2
BLDDIR  = brlcad-build

DEB_SCRIPT  = make-brlcad-deb-packages.sh

BLD_ARGS  = rel
#BLD_ARGS = deb
#BLD_ARGS += pdf

# set configure options
include Makefile.brlcad-options

# define dirs in the build directory that may be cleaned
include Makefile.build-files

all:
	@echo "Set for BRL-CAD version '$(BVERSION)'."
	@echo " "
	@echo "Enter 'make build-clean' to remove build files in"
	@echo "  '$(BLDDIR)'."
	@echo " "
	@echo "Enter 'make config' to remove build files in"
	@echo "  '$(BLDDIR)' and reconfigure the directory."
	@echo " "
	@echo "Enter 'make check' to check for pre-requisites."
	@echo " "
	@echo "Enter 'make deb' to build the deb packages."

deb:
	@echo "Building Debian packages..."
	( cd $(BLDDIR); ../$(DEB_SCRIPT) -b | tee build.log )

check:
	@echo "Checking for pre-requisites..."
	( cd $(BLDDIR); ../$(DEB_SCRIPT) -b -t )

clean: build-clean

build-clean:
	@echo "Removing all but the 'debian' dir in directory '$(BLDDIR)'..."
	( cd $(BLDDIR); rm $(BUILD_FILES); rm -rf $(BUILD_DIRS) )
	@echo "See 'debian' dir in directory '$(BLDDIR)'..."

conf: config

config: build-clean
	@echo "Copying some extra files to directory '$(BLDDIR)'..."
	mkdir -p $(BLDDIR)/include/conf
	cp $(SRCDIR)/include/conf/MAJOR $(BLDDIR)/include/conf
	cp $(SRCDIR)/include/conf/MINOR $(BLDDIR)/include/conf
	cp $(SRCDIR)/include/conf/PATCH $(BLDDIR)/include/conf
	@echo "Reconfiguring directory '$(BLDDIR)'..."
	( unset BRLCAD_ROOT ; cd $(BLDDIR) ; cmake ../$(SRCDIR) $(RELEASE_OPTIONS) )
