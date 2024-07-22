#!/bin/bash

#Compile postgis

set -e

echo "compile postgis start"

configure_args=$(cat ../src/Makefile.global | grep "configure_args" | awk -F "configure_args =" '{ print $NF }')
echo "configure_args:"${configure_args}

prefix_args=$( cat ../src/Makefile.global | grep "configure_args" | awk -F "configure_args =" '{ print $NF }' | sed "s/'//g" | awk -F "prefix=" '{ print $NF }' | awk '{ print $1 }' )
echo "prefix_args:"${prefix_args}

export PATH=${prefix_args}/bin:$PATH
export LD_LIBRARY_PATH=${prefix_args}/lib:$LD_LIBRARY_PATH

# echo "compile zstd......"
# cd zstd/
# pwd
# make -sj
# #no need make install, copy zstd.so is ok
# cp -r lib/*.h ${prefix_args}/include/
# cp -r lib/libzstd.so.1.5.2 ${prefix_args}/lib/
# echo "end compile zstd......"


echo "start compile sqlite-autoconf-3390400......"
# cd ..
tar zxf sqlite-autoconf-3390400.tar.gz
cd sqlite-autoconf-3390400/ 
pwd
chmod +x configure
./configure --prefix=${prefix_args}
make clean
make -sj15
make install
echo "end compile sqlite-autoconf-3390400......"


echo "start compile proj-6.2.0......"
cd ..
tar zxf proj-6.2.0.tar.gz
local_googletest_path=`realpath googletest-release-1.8.1.zip`
sed -i "s#https://github.com/google/googletest/archive/release-1.8.1.zip#${local_googletest_path}#g" proj-6.2.0/test/googletest/CMakeLists.txt.in
cd proj-6.2.0/
pwd
rm -rf build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${prefix_args} -DSQLITE3_INCLUDE_DIR=${prefix_args}/include/ -DSQLITE3_LIBRARY=${prefix_args}/lib/libsqlite3.so ..
make clean
make -sj15
make install
cp -r ${prefix_args}/lib64/* ${prefix_args}/lib/
cd ..
echo "end compile proj-6.2.0......"


echo "start compile gdal-3.4.1......"
cd ..
tar zxf gdal-3.4.1.tar.gz 
cd gdal-3.4.1/ 
pwd
chmod +x configure
./configure --prefix=${prefix_args} --with-proj=${prefix_args}  CPPFLAGS=-I${prefix_args}/include LDFLAGS=-L${prefix_args}/lib
make clean
make -sj15
make install
echo "end compile gdal-3.4.1......"


echo "start compile geos-3.9.3......"
cd ..
tar xf geos-3.9.3.tar.bz2
cd geos-3.9.3/
pwd
chmod +x configure
./configure --prefix=${prefix_args} CPPFLAGS=-I${prefix_args}/include LDFLAGS=-L${prefix_args}/lib 
make clean
make -sj15
make install
echo "end compile geos-3.9.3......"


echo "start compile protobuf-3.7.1......"
cd ..
tar zxf protobuf-3.7.1.tar.gz 
cd protobuf-3.7.1/
pwd
chmod +x autogen.sh 
./autogen.sh 
chmod +x configure
./configure --prefix=${prefix_args} CPPFLAGS=-I${prefix_args}/include LDFLAGS=-L${prefix_args}/lib 
make clean
make -sj15
make install
echo "end compile protobuf-3.7.1......"


echo "start compile protobuf-c-1.4.0......"
cd ..
tar zxf protobuf-c-1.4.0.tar.gz
cd protobuf-c-1.4.0/
pwd
export PROTOBUF_CFLAGS=${prefix_args}/lib/libprotobuf.so 
export PROTOBUF_LIBS=${prefix_args}/lib/libprotobuf.so 
export C_INCLUDE_PATH=${prefix_args}/include
export PKG_CONFIG_PATH=${prefix_args}/lib/pkgconfig
chmod +x autogen.sh 
./autogen.sh 
./configure --prefix=${prefix_args} CPPFLAGS=-I${prefix_args}/include LDFLAGS=-L${prefix_args}/lib 
make clean
make -sj15
make
make install
echo "end compile protobuf-c-1.4.0......" 


echo "start compile postgis-for-opentenbase......"
cd ../postgis-for-opentenbase/
pwd
export PATH=${prefix_args}/bin:$PATH
export LD_LIBRARY_PATH=${prefix_args}/lib:$LD_LIBRARY_PATH
chmod +x autogen.sh
./autogen.sh
# ./configure --prefix=${prefix_args}  --with-pgconfig=${prefix_args}/bin/pg_config --with-geosconfig=${prefix_args}/bin/geos-config --with-gdalconfig=${prefix_args}/bin/gdal-config  --with-projdir=${prefix_args}/ CPPFLAGS=-I${prefix_args}/include LDFLAGS=-L${prefix_args}/lib
./configure --prefix=${prefix_args}  --with-pgconfig=${prefix_args}/bin/pg_config --with-geosconfig=${prefix_args}/bin/geos-config --with-gdalconfig=${prefix_args}/bin/gdal-config  CPPFLAGS=-I${prefix_args}/include LDFLAGS=-L${prefix_args}/lib
make clean
make -sj15
make install
echo "end compile postgis-for-opentenbase"

cd ../

