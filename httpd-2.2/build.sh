#!/bin/bash

VERSION="$1"
if [ "n$VERSION" == "n" ]; then
    echo "No version specified"
    exit -1
fi

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

# Build HTTPD 2.2.x
./configure \
	--prefix=/tmp/staged/app/httpd \
	--enable-mods-shared=all \
	--enable-so \
	--with-mpm=worker
make -j 3
make install
cd ../

# Build mod_fcgid
cd mod_fcgid-2.3.9
make clean
APXS=/tmp/staged/app/httpd/bin/apxs ./configure.apxs 
make -j 3
make install
cd ../

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
sed 's/\/tmp\/staged\/app/\${HOME}/g' apr-1-config > apr-1-config.fixed
mv apr-1-config.fixed apr-1-config
chmod 755 apr-1-config
sed 's/\/tmp\/staged\/app/\${HOME}/g' apu-1-config > apu-1-config.fixed
mv apu-1-config.fixed apu-1-config
chmod 755 apu-1-config
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
