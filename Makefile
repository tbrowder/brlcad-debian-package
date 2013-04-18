# need to completely clean up after a Debian build

# important: set BRL-CAD version here
#BVERSION = 7.22.0
BVERSION = 7.23.1

SHELL   = /bin/bash
SRCDIR  = brlcad-$(BVERSION)
ODIR    = brlcad_$(BVERSION)

# all files in the build dir are auto-generated
BLDDIR  = build-tmp
SFIL    = brlcad-info.sh

TOPDIR := $(shell pwd)

DEBDIR := ./debian
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
	@echo "Enter 'make clean' to remove all files in"
	@echo "  '$(BLDDIR)'."
	@echo " "
	@echo "Enter 'make deb' to build the binary deb packages."
	@echo "Enter 'make src' to build the source deb package."
	@echo "Enter 'make build' to build BRL-CAD."

# this is looking usable; need to use vars for some things; add cmake
# options into rules file
conf:
	@echo "Configuring directory '$(BLDDIR)'..."
	( unset BRLCAD_ROOT ; cd $(SRCDIR) ; \
           dh_auto_configure --verbose --builddirectory=$(TOPDIR)/$(BLDDIR) \
           --buildsystem=cmake --parallel)

build:
	@echo "Building BRL-CAD in '$(TOPDIR)/$(BLDDIR)'..."
	( cd -r $(TOPDIR)/$(SRCDIR) ; debian/rules build )
	dpkg-source -b $(TOPDIR)/$(SRCDIR)

deb: $(SFIL)
	@echo "Building Debian binary packages..."
	( cd $(BLDDIR); $(TOPDIR)/$(DEB_SCRIPT) -b | tee build.log )

src: $(SFIL)
	@echo "Building Debian source package..."
	( rm -rf $(TOPDIR)/$(SRCDIR)/debian )
	( cp -r $(TOPDIR)/$(DEBDIR) $(TOPDIR)/$(SRCDIR) )
	dpkg-source -b $(TOPDIR)/$(SRCDIR)

check: $(SFIL)
	@echo "Checking for pre-requisites..."
	( cd $(BLDDIR); $(TOPDIR)/$(DEB_SCRIPT) -b -t )

clean:
	@echo "Removing all but the 'debian' dir in directory '$(BLDDIR)'..."
	( cd $(BLDDIR); rm $(BUILD_FILES); rm -rf $(BUILD_DIRS) )
	@echo "See 'debian' dir in directory '$(BLDDIR)'..."
