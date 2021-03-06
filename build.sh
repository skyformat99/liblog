#!/bin/sh

CMD=$0
PLATFORM=$1
DIR=${PWD}

usage()
{
	echo "==== usage ===="
	echo "$CMD [platform]"
	echo "<platform>: arm, x86(default)"
}

do_make()
{
	./configure ${HOST}
	make
}

do_package()
{
	make distclean
	rm .libs/ -fr
	rm .deps/ -fr
	rm ./debian/.debhelper/ -fr
	cd ../
	if [ -f liblog_1.0.2.orig.tar.xz ]; then
		rm liblog_1.0.2.orig.tar.xz
	fi
	tar -Jcvf liblog_1.0.2.orig.tar.xz liblog \
	--exclude liblog/.git \
	--exclude liblog/.libs \
	--exclude liblog/.deps \
	--exclude liblog/.pc
	cd ${DIR}
	dpkg-buildpackage
}

do_ppa()
{
	rm .libs/ -fr
	dpkg-buildpackage -S
	debuild -S -k6A210E88
	dput ppa:gozfree/ppa ../liblog_1.0.2_source.changes
}

do_build()
{
	case $PLATFORM in
	"arm")
		HOST="--host=arm-linux-gnueabihf";;
	"deb")
		do_package;
		exit;;
	"ppa")
		do_ppa;
		exit;;
	"help")
		usage;
		exit;;
	"clean")
		make clean;
		exit;;
	*)
		HOST="";;
	esac
}

do_build
do_make
