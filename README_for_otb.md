# Postgis for OpenTenBase


## Introduction

This repo is a modified version of postgis extension based on Postgis 3.2.1. This version aims to enable the PostGIS extension to support the distributed features of OpenTenBase and to provide as much support as possible for any issues users may encounter during its use.




## How to install


```shell
SOURCECODE_PATH=/your/path/to/OpenTenBase/source/code
INSTALL_PATH=/your/path/to/install/

# Get source code of Opentenbase
cd ${SOURCE_CODE_PATH}
git clone https://github.com/OpenTenBase/OpenTenBase

# Build & Install
cd ${SOURCECODE_PATH}/OpenTenBase
rm -rf ${INSTALL_PATH}/opentenbase_bin_v2.0
chmod +x configure*
./configure --prefix=${INSTALL_PATH}/opentenbase_bin_v2.0 --enable-regress --enable-user-switch --with-openssl --with-ossp-uuid CFLAGS="-g -DPGXC -D_PG_ORCL -DXCP  -D_USER_SWITCH_"
make clean
make -sj
make install
chmod +x contrib/pgxc_ctl/make_signature
cd contrib
make -sj
make install

# Get source code of postgis-for-otb
cd ${SOURCE_CODE_PATH}/contrib
git clone https://github.com/dfzhang2022/postgis-for-opentenbase.git

# Get dependency tarball

# The following tools are needed:
#     sqlite-autoconf-3390400
#     googletest-release-1.8.1
#     proj-6.2.0
#     gdal-3.4.1
#     geos-3.9.3
#     protobuf-3.7.1
#     protobuf-c-1.4
wget https://mirrors.aliyun.com/macports/distfiles/sqlite3/sqlite-autoconf-3390400.tar.gz

wget https://github.com/google/googletest/archive/refs/tags/release-1.8.1.zip
mv ./release-1.8.1.zip ./googletest-release-1.8.1.zip

wget https://download.osgeo.org/proj/proj-6.2.0.tar.gz

wget https://download.osgeo.org/gdal/3.4.1/gdal-3.4.1.tar.gz

wget https://download.osgeo.org/geos/geos-3.9.3.tar.bz2

wget https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-all-3.7.1.tar.gz
mv ./protobuf-all-3.7.1.tar.gz ./protobuf-3.7.1.tar.gz 

wget https://github.com/protobuf-c/protobuf-c/releases/download/v1.4.0/protobuf-c-1.4.0.tar.gz



# Compile dependency & postgis
cp ./postgis-for-opentenbase/deps/postgis_compile.sh ./
./postgis_compile.sh

# Then postgis extension has already built & installed to your OpenTenBase installation dir.

```


## How to test
```shell

cd ${SOURCE_CODE_PATH}/contrib/postgis-for-opentenbase/
rm -r /tmp/pgis_reg/* 
make installcheck # This would output result to cmd line.

# If user wants to read from /tmp/res.txt, redirecting output using this cmd below.
# make installcheck > /tmp/res.txt 2>&1 

```


## How to use
```shell

psql -U [USER_NAME] -p [PORT] -d [DB_NAME] -h [HOST_IP]

CREATE EXTENSION postgis;

```