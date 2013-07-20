Build scripts for cf-php-apache-buildpack binaries
==================================================

This repo contains helper scripts for creating binaries for the following:

    - HTTPD 2.2
    - HTTPD 2.4
    - PHP 5.3
    - PHP 5.4
    - PHP 5.5

Build Information
-----------------

The build pack makes use of binary versions of Apache HTTPD and PHP.  These are unmodified versions of the software that are downloaded into the environment in a binary form so that they do not have to be compiled prior to being used.  In the event that you'd like to compile your own versions of the software, these scripts can be used to quickly do that.

###Environment

The environment used to compile the files was a fully up-to-date Ubuntu 10.04.4 LTS system.  The easiest way to get all of the build tools is to install the build-essential and autoconf packages.  Beyond that, you'll need libraries and dev packages for things like MySQL, PostgresSQL, aspell, mcrypt, libc-client, gettext, openssl, gdb, bz2 and anything else that you want to compile support for into PHP.

###Apache Build

Check out the httpd-2.2 or httpd-2.4 folders and look for the build-instructions.txt file.  This contains the steps for building each binary.

In most cases this roughly equates to the following:
    - Make sure the system is up-to-date
    - Make sure any pre-requisite libraries are up-to-date
    - Run build.sh

After the build completes, in ```/tmp/staged/app``` you see a gzip file and a sha1 file, which has the checksum for the gzip archive.  Once you have the zip and sha file, you can delete the source and anything under ```/tmp/staged/app```.

###PHP Build

The PHP build is a bit more complicated as it depends on quite a few things.  The default build provided with this build pack tries to include all of the modules that you would need to connect to the services available on CloudFoundry.  This includes MySQL, PostgreSQL, Redis, Mongo and RabbitMQ.

Check out the php-5.3, php-5.4 or php-5.5 folders and look at the build-instructions.txt file for step-by-step instructions.

In most cases this roughly equates to the following:
    - Make sure the system is up-to-date
    - Make sure any pre-requisite libraries are up-to-date
    - For PHP, make sure any extensions are up-to-date
    - Run build.sh

After the build completes, in ```/tmp/staged/app``` you see a gzip file and a sha1 file, which has the checksum for the gzip archive.  Once you have the zip and sha file, you can delete the source and anything under ```/tmp/staged/app```.

###Distribution

Distribution of your builds is simple.  Place them on a web server so that they are public.  From there edit *options.json* and set the *DOWNLOAD_URL* option to point to the directory on your web server.  As long as you have followed the packaging instructions above, the build pack should be able to consume your binaries.
