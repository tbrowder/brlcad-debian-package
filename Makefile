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
	@echo "Enter 'make build-clean' to remove build files in"
	@echo "  ($(BLDDIR)).
	@echo " "
	@echo "Enter 'make config' to remove build files in"
	@echo "  ($(BLDDIR)) and reconfigure the directory.
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

build-clean:
	@echo "Removing all but the 'debian' dir in directory '$(BLDDIR)'..."
	( cd $(BLDDIR); rm $(BUILD_FILES); rm -rf $(BUILD_DIRS) )

config: build-clean
	@echo "Copying some extra files to directory '$(BLDDIR)'..."
	mkdir -p $(BLDDIR)/include/conf
	cp $(SRCDIR)/include/conf/MAJOR $(BLDDIR)/include/conf
	cp $(SRCDIR)/include/conf/MINOR $(BLDDIR)/include/conf
	cp $(SRCDIR)/include/conf/PATCH $(BLDDIR)/include/conf
	@echo "Reconfiguring directory '$(BLDDIR)'..."
	( unset BRLCAD_ROOT ; cd $(BLDDIR) ; cmake ../$(SRCDIR) $(RELEASE_OPTIONS) )


dist-clean:
	@echo "Removing directory '$(SRCDIR)'..."
	-rm -rf $(SRCDIR)

clean: set-version
	@echo "Removing directory '$(SRCDIR)'..."
	-rm -rf $(SRCDIR)
	@echo "Unpacking a fresh copy of directory '$(SRCDIR)'..."
	-tar -xvjf $(PKG)
	$(MAKE) prep
	@echo "============================================="
	@echo "Now CD into the '$(SRCDIR)' directory and run:"
	@echo " "
	@echo "  # check for prereqs:"
	@echo "  ./make-value-brlcad-deb-cmake.sh -b -t"
	@echo " "
	@echo "  # build deb and save output to a log file:"
	@echo "  ./make-value-brlcad-deb-cmake.sh -b | tee build.log"

prep: set-version
	@echo "Linking build script into directory '$(SRCDIR)'..."
	(cd $(SRCDIR) ; ln -sf $(SCRIPT) . )

# files and dirs to handle
F1   := ../debian-brlcad-cmake/etc/profile.d/brlcad.sh
F1C1 := ./brlcad.sh.common.1
F1C2 := ./brlcad.sh.common.2

F2 := ../debian-brlcad-cmake/etc/brlcad/version

F3 := ../../update_vuser_bash_alias.pl
D3 := ../debian-brlcad-cmake/usr/local/bin

#F4 := ../../update-value-brlcad-libs.pl
#D4 := ../debian-brlcad-cmake/usr/local/bin

#F5 := ../../fix-v19-value-brlcad-libs.pl
#D5 := ../debian-brlcad-cmake/usr/local/bin

F6 := ../debian-brlcad-cmake/etc/ld.so.conf.d/brlcad.conf

# watch the escaping below for paths: "\$$PATH" yields "$PATH" in the
# output file which is what is desired
LPATH=/usr/brlcad/rel-${VERSION}/lib
set-version:
	@echo "Writing file '${F1}'..."
	cat ${F1C1}                   >  ${F1}
	@echo "BRLCADVER=${VERSION}"  >> ${F1}
	cat ${F1C2}                   >> ${F1}

	@echo "Writing file '${F2}'..."
	@echo "${VERSION}" >  ${F2}

	@echo "Copying file '${F3}' to dir '${D3}'..."
	@cp ${F3} ${D3}

	@echo "Writing file '${F6}'..."
	@echo "# added by the BRL-CAD installer" >  ${F6}
	@echo "${LPATH}"                         >> ${F6}
