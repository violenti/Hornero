#!/bin/bash

if [ -e /var/db/pkg.real ];then
    echo "Fixing packages database..."
    mv /var/db/pkg /var/db/pkg.kit
    mv /var/db/pkg.real /var/db/pkg
    echo "Done!"
fi

rm -rf /var/tmp/portage/*
cp uses/package.use.ututo /usr/portage/profiles/base/package.use
cat `ls compile.list/compile.list.* | grep -v compile.list.pkg | grep -v compile.list.ori` > compile.list/compile.list
. /etc/profile

ARQ="i686"
PARM="-b"
RECOMPILA="R"  # X=Yes   R=No
ALTFLAGS="fast"
cp makes.conf.fast/make.conf.$ARQ /etc/make.conf
while read PKG
do
    SIONO=`echo "$PKG" | grep "\[ebuild   $RECOMPILA"`
    if [ "$SIONO" = "" ];then
	#echo "Processing... $PKG"
	PKGX=`echo $PKG | cut -d "]" -f 2 | cut -d " " -f 2 | cut -d ":" -f 1`
	USEX3=`echo $PKG | cut -d "=" -f 2 | cut -d "\"" -f 2 | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//" | sed "s/(//" | sed "s/)//"`
	USEX2=`echo $USEX3 | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//" | sed "s/*//"`
	USEXX=`echo $USEX2 | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//" | sed "s/%//"`
	USEX=`echo $USEXX | sed "s/ssse3//" | sed "s/sse3//" | sed "s/sse4//" | sed "s/sse2//" | sed "s/sse//" | sed "s/mmx//" |  sed "s/3dnow//"`
	USEMAKE=`cat /etc/make.conf | grep USE | grep -v USE_ | cut -d "\"" -f 2`
	#PKGX2=`echo $PKG | cut -d "]" -f 2 | cut -d " " -f 2 | cut -d "/" -f 2 | sed "s/\:\:gentoo//" | sed "s/\:\:gentoo//" | sed "s/\:\:sugar//" | sed "s/\:\:sabayon//" | sed "s/\:1//" | sed "s/\:2//" | sed "s/\:3//" | sed "s/\:4//" | cut -d ":" -f 1`
	PKGX2=`echo $PKG | cut -d "]" -f 2 | cut -d " " -f 2 | cut -d "/" -f 2 | cut -d ":" -f 1`
	CATE=`echo $PKG | cut -d "/" -f 1 | cut -d "]" -f 2 | sed "s/ //g"`
	if [ -e packages/$ARQ/$PKGX2.tbz2 ];then
	    sleep 0
	else
	    echo "Buscando en $CATE el paquete $PKGX2 (1)"
	    EXISTE=`find /var/db/pkg/$CATE/ -type f -name '*.ebuild' -print | sed -e "s/.ebuild//" | grep "$PKGX2" | cut -d "/" -f 7`
	    if [ "$EXISTE" != "$PKGX2" ];then
		wget packages.ututo.org/utiles/00Testing/i686/$PKGX2.tbz2
		if [ -e $PKGX2.tbz2 ];then
		    mkdir /usr/portage/packages/All
		    mv $PKGX2.tbz2 /usr/portage/packages/All
		    #mv $PKGX2.tbz2 packages/$ARQ
		    ACTUAL=`pwd`
		    cd /usr/portage/packages/All
		    emerge --nodeps -K $PKGX2.tbz2
		    rm -rf $PKGX2.tbz2
		    cd $ACTUAL
		fi
	    fi
	fi
	if [ -e packages/$ARQ/$PKGX2.tbz2 ];then
	    echo "Compiled ... $PKGX"
	    #sleep 3
	else
	    echo "Buscando en $CATE el paquete $PKGX2 (2)"
	    EXISTE=`find /var/db/pkg/$CATE/ -type f -name '*.ebuild' -print | sed -e "s/.ebuild//" | grep "$PKGX2" | cut -d "/" -f 7`
	    if [ "$EXISTE" != "$PKGX2" ];then
		clear
		echo "------------------------------------------------------------------"
		echo "Paquete: $CATE / $PKGX ($EXISTE != $PKGX2)"
		echo "USE: $USEMAKE $USEX"
		echo "------------------------------------------------------------------"
		echo " "
		cp makes.conf.fast/make.conf.$ARQ /etc/make.conf
		USE="$USEMAKE $USEX" emerge --nodeps $PARM =$PKGX
		if [ -e /usr/portage/packages/All/$PKGX2.tbz2 ];then
		    mkdir packages/$ARQ
		    mv /usr/portage/packages/All/*.tbz2 packages/$ARQ
		else
		    cp makes.conf/make.conf.$ARQ /etc/make.conf
		    USE="$USEMAKE $USEX" emerge --nodeps $PARM =$PKGX
		    if [ -e /usr/portage/packages/All/$PKGX2.tbz2 ];then
			mkdir packages/$ARQ
			mv /usr/portage/packages/All/*.tbz2 packages/$ARQ
		    else
			echo "Compilation Error in $PKGX"
			sleep 1000000
			#read -t 1000000
		    fi
		fi
	    else
		echo "Package in local database installed! ($CATE/$PKGX2)"
	    fi
	fi
    else
	echo "Compilado en el sistema... $PKG"
    fi
done < compile.list/compile.list
# return to original
cp makes.conf/make.conf.i686 /etc/make.conf
cp uses/package.use.ututo /usr/portage/profiles/base/package.use

