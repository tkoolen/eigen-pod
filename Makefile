DL_LINK   = http://bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2
DL_NAME   = 3.2.4.tar.bz2
TAR_NAME = 3.2.4.tar
UNZIP_DIR = eigen-eigen-10219c95fe65

#default_target: all

BUILD_SYSTEM:=$(OS)
ifeq ($(BUILD_SYSTEM),Windows_NT)
BUILD_SYSTEM:=$(shell uname -o 2> NUL || echo Windows_NT) # set to Cygwin if appropriate
else
BUILD_SYSTEM:=$(shell uname -s)
endif
BUILD_SYSTEM:=$(strip $(BUILD_SYSTEM))

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq ($(BUILD_SYSTEM), Windows_NT)
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell (for %%x in (. .. ..\.. ..\..\.. ..\..\..\..) do ( if exist %cd%\%%x\build ( echo %cd%\%%x\build & exit ) )) & echo %cd%\build )
endif
# don't clean up and create build dir as I do in linux.  instead create it during configure.
else
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)
endif

ifeq "$(BUILD_SYSTEM)" "Cygwin"
  BUILD_PREFIX:=$(shell cygpath -m $(BUILD_PREFIX))
endif
PKG_CONFIG_LIBDIR:=$(BUILD_PREFIX)/lib
export PKG_CONFIG_LIBDIR

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
  BUILD_TYPE="Release"
endif

SED=sed
ifeq ($(BUILD_SYSTEM),Darwin)
  SED=gsed
endif

all: pod-build/Makefile
	cmake --build pod-build --config $(BUILD_TYPE) --target install

pod-build/Makefile:
	$(MAKE) configure

.PHONY: configure
configure: $(UNZIP_DIR)/CMakeLists.txt
#	@echo "BUILD_SYSTEM: '$(BUILD_SYSTEM)'"
	@echo "BUILD_PREFIX: $(BUILD_PREFIX)"

# create the temporary build directory if needed
# create the lib directory if needed, so the pkgconfig gets installed to the right place
ifeq ($(BUILD_SYSTEM), Windows_NT)
	@if not exist $(BUILD_PREFIX) ( mkdir $(BUILD_PREFIX) )
	@if not exist pod-build ( mkdir pod-build )
	@if not exist $(BUILD_PREFIX)\lib ( mkdir $(BUILD_PREFIX)\lib )
	@if not exist $(BUILD_PREFIX)\lib\pkgconfig ( mkdir $(BUILD_PREFIX)\lib\pkgconfig )
else
	@mkdir -p pod-build
	@mkdir -p $(BUILD_PREFIX)/lib
	@mkdir -p $(BUILD_PREFIX)/lib/pkgconfig
endif

# run CMake to generate and configure the build scripts
	@cd pod-build && cmake $(CMAKE_FLAGS) -DCMAKE_INSTALL_PREFIX=$(BUILD_PREFIX) \
	       	-DEIGEN_BUILD_PKGCONFIG=ON -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ../$(UNZIP_DIR) 

$(UNZIP_DIR)/CMakeLists.txt:
	wget --no-check-certificate $(DL_LINK)
	bzip2 -d $(DL_NAME)
	tar -xf $(TAR_NAME)
#	$(SED) -i -e 's@share/pkgconfig@lib/pkgconfig@g' $(UNZIP_DIR)/CMakeLists.txt
ifeq ($BUILD_SYSTEM,Windows_NT)
	-del $(DL_NAME) $(TAR_NAME)
else
	-rm $(DL_NAME) $(TAR_NAME)
endif

release_filelist:
# intentionally left blank

clean:
ifeq ($(BUILD_SYSTEM),Windows_NT)
	rd /s pod-build
else
	-if [ -e pod-build/install_manifest.txt ]; then rm -f `cat pod-build/install_manifest.txt`; fi
	-if [ -d pod-build ]; then cmake --build pod-build --target clean; rm -rf pod-build; fi
endif

# other (custom) targets are passed through to the cmake-generated Makefile
%::
	cmake --build pod-build --config $(BUILD_TYPE) --target $@

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:
