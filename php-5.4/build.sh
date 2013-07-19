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
    curl -L -o php-$VERSION.tar.bz2 http://us2.php.net/get/php-$VERSION.tar.bz2/from/us3.php.net/mirror
    tar jxf php-$VERSION.tar.bz2
    rm php-$VERSION.tar.bz2
fi

cd php-$VERSION

# Build PHP 5.3
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
	--enable-pear \
	--with-bz2=shared \
	--with-curl=shared \
	--enable-dba=shared \
	--with-inifile \
	--with-flatfile \
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
	--with-exif=shared \
	--with-openssl=shared \
	--enable-fpm
make
make install
cd ../

# Copy required libs to /tmp/staged/app
cp required-libs/* /tmp/staged/app/php/lib/

# Build extensions
cd php-extensions

# Build RabbitMQ Libs
cd rabbitmq-c-rabbitmq-c-v0.3.0
make clean
./configure --prefix=/tmp/staged/app/librmq
make
make install
cd ../

# build AMQP extension
cd amqp-1.2.0
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config --with-librabbitmq-dir=/tmp/staged/app/librmq
make
make install
cd ../

# build APC
cd APC-3.1.9
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config
make
make install
cd ../

# build mongo
cd mongo-1.4.1
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config
make
make install
cd ../

# build redis
cd redis-2.2.3
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config
make
make install
cd ../

# build xdebug
cd xdebug-2.2.3
make clean
/tmp/staged/app/php/bin/phpize
./configure --with-php-config=/tmp/staged/app/php/bin/php-config
make
make install
cd ../

# Remove unused files
cd /tmp/staged/app/php
rm -rf php/ include/

# Build binary
cd ../
mv php php-$VERSION-bin
tar czf php-$VERSION-bin.tar.gz php-$VERSION-bin

echo "Done!"

