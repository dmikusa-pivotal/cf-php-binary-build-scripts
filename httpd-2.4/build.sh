#!/bin/bash

VERSION="$1"
if [ "n$VERSION" == "n" ]; then
    echo "No version specified"
    exit -1
fi

# Build pre-requisite libraries
cd build-requirements

# Build apr
cd apr-1.4.8
make clean
./configure --prefix=/tmp/staged/app/libapr-1.4.8
make
make install
cd ../

# Build iconv
cd apr-iconv-1.2.1
make clean
./configure \
	--prefix=/tmp/staged/app/libapr-iconv-1.2.1 \
	 --with-apr=/tmp/staged/app/libapr-1.4.8/bin/apr-1-config
make
make install
cd ../

# Build apr-util
cd apr-util-1.5.2
make clean
./configure \
	--prefix=/tmp/staged/app/libapr-util-1.5.2 \
	--with-iconv=/tmp/staged/app/libapr-iconv-1.2.1 \
	--with-crypto \
	--with-openssl \
	--with-mysql \
	--with-pgsql \
	--with-gdbm \
	--with-ldap \
	--with-apr=/tmp/staged/app/libapr-1.4.8
make
make install
cd ../

# Done with pre-requisites
cd ../

# curl download file - follow redirect, output to file
if [ -f httpd-$VERSION.tar.bz2 ]; then
    rm httpd-$VERSION.tar.bz2
fi
if [ ! -d httpd-$VERSION ]; then
    curl -L -o httpd-$VERSION.tar.bz2 http://apache.osuosl.org//httpd/httpd-$VERSION.tar.bz2
fi

tar jxf httpd-$VERSION.tar.bz2
rm httpd-$VERSION.tar.bz2
cd httpd-$VERSION

# Build HTTPD 2.4
./configure \
	--prefix=/tmp/staged/app/httpd \
	--with-apr=/tmp/staged/app/libapr-1.4.8 \
	--with-apr-util=/tmp/staged/app/libapr-util-1.5.2 \
	--enable-mpms-shared='worker event' \
	--enable-mods-shared=reallyall
make
make install
cd ../

# Copy required libraries
mkdir /tmp/staged/app/httpd/lib
cp required-libs/* /tmp/staged/app/httpd/lib

# Remove unnecessary files and config
cd /tmp/staged/app/httpd
rm -rf build cgi-bin/ error/ icons/ include/ man/ manual/ htdocs/
rm -rf conf/extra/* conf/httpd.conf conf/httpd.conf.bak conf/magic conf/original

# Fix start scripts
cd /tmp/staged/app/httpd/bin

# fix hard-coded path with env variable
sed 's/\/tmp\/staged\/app/\${HOME}/g' apachectl > apachectl.fixed
mv apachectl.fixed apachectl
chmod 755 apachectl
sed 's/\/tmp\/staged\/app/\${HOME}/g' envvars > envvars.fixed
mv envvars.fixed envvars
chmod 755 envvars
sed 's/\/tmp\/staged\/app/\${HOME}/g' envvars-std > envvars-std.fixed
mv envvars-std.fixed envvars-std
chmod 755 envvars-std

# switch single to double quotes so variable expansion occurs
sed -r "s/HTTPD='(.*)'/HTTPD=\"\1\"/g" apachectl > apachectl.fixed
mv apachectl.fixed apachectl
chmod 755 apachectl

# Package the binary
cd /tmp/staged/app
mv httpd httpd-$VERSION-bin
tar czf httpd-$VERSION-bin.tar.gz httpd-$VERSION-bin
shasum httpd-$VERSION-bin.tar.gz > httpd-$VERSION-bin.tar.gz.sha1

echo "Done!"
