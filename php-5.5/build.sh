#!/bin/bash

VERSION="$1"
if [ "n$VERSION" == "n" ]; then
    echo "No version specified"
    exit -1
fi

# quiet, follow redirect, output to file
if [ -f php-$VERSION.tar.bz2 ]; then
    rm php-$VERSION.tar.bz2
fi
if [ ! -d php-$VERSION ]; then
    curl -L -o php-$VERSION.tar.bz2 http://us1.php.net/get/php-$VERSION.tar.bz2/from/us2.php.net/mirror
    tar jxf php-$VERSION.tar.bz2
    rm php-$VERSION.tar.bz2
fi

cd php-$VERSION

# Build PHP 5.5
./configure \
	--prefix=/tmp/staged/app/php \
	--with-config-file-path=/home/vcap/app/php/etc \
	--enable-cli \
	--enable-ftp \
	--enable-sockets \
	--enable-soap \
	--enable-fileinfo \
	--enable-bcmath \
	--enable-calendar \
	--with-kerberos \
	--enable-zip \
	--with-pear \
	--with-bz2=shared \
	--with-curl=shared \
	--enable-dba=shared \
	--with-cdb \
	--with-gdbm \
	--with-mcrypt=shared \
	--with-mhash=shared \
	--with-mysql=mysqlnd \
	--with-mysqli=mysqlnd \
	--with-pdo-mysql=mysqlnd \
	--with-gd=shared \
	--with-pdo-pgsql=shared \
	--with-pgsql=shared \
	--with-pspell=shared \
	--with-gettext=shared \
	--with-gmp=shared \
	--with-imap=shared \
	--with-imap-ssl=shared \
	--with-ldap=shared \
	--with-ldap-sasl \
	--enable-mbstring \
	--enable-mbregex \
	--enable-exif=shared \
	--with-openssl=shared \
	--enable-fpm
make -j 3
make install
cd ../

# Copy required libs to /tmp/staged/app
cp required-libs/* /tmp/staged/app/php/lib/

# Build extensions
cd php-extensions

# Build RabbitMQ Libs
cd rabbitmq-c-0.4.1
make clean
./configure --prefix=/tmp/staged/app/librmq
make -j 3
make install
cp /tmp/staged/app/librmq/lib/librabbitmq.so.1 /tmp/staged/app/php/lib/
cd ../

# build AMQP extension
cd amqp-1.2.0
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config --with-librabbitmq-dir=/tmp/staged/app/librmq
make -j 3
make install
cd ../

# build mongo
cd mongo-1.4.5
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config
make -j 3
make install
cd ../

# build redis
cd redis-2.2.4
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config
make -j 3
make install
cd ../

# build xdebug
cd xdebug-2.2.3
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config
make -j 3
make install
cd ../

# Remove unused files
cd /tmp/staged/app/php
rm -rf php/ include/

# Build binary
cd ../
mv php php-$VERSION-bin
tar czf php-$VERSION-bin.tar.gz php-$VERSION-bin
shasum php-$VERSION-bin.tar.gz > php-$VERSION-bin.tar.gz.sha1

echo "Done!"

