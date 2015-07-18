cmake_minimum_required(VERSION 2.8.0)
project(eigen)

include(ExternalProject)

#set(ENV{PKG_CONFIG_LIBDIR} "${CMAKE_INSTALL_PREFIX}/lib")
# Note: this doesn't survive through to the configure step of the extenal project (http://cmake.3232098.n2.nabble.com/Pass-PATH-to-ExternalProject-Add-td5788195.html).  added an install version below

ExternalProject_Add(eigen
  URL https://bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2
  URL_HASH MD5=4c4b5ed9a388a1e475166d575af25477
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DEIGEN_BUILD_PKGCONFIG=ON $ENV{CMAKE_FLAGS})

# this was cleaner (more platform independent) than writing a wrapper shell script around CMAKE
ExternalProject_Get_Property(eigen BINARY_DIR)
install(FILES ${BINARY_DIR}/eigen3.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)
