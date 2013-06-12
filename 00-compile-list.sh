#!/bin/bash

if [ "$1" = "" ];then
    VERSION1=`cat kit.lastversion`
    wget packages.ututo.org/utiles/kit/kit.lastversion
    VERSION2=`cat kit.lastversion.1`
    rm -rf kit.lastversion.1
    if [ "$VERSION1" != "$VERSION2" ];then
	clear
	echo "----------------------------------------------------"
	echo "Kit for UTUTO XS need upgrade $VERSION1 != $VERSION2"
	echo " "
	echo "Please download new version from:"
	echo "http://packages.ututo.org/utiles/kit/"
	echo " "
	echo "Exiting!!"
	exit
    else
	#clear
	echo "----------------------------------------------------"
	echo "UTUTO XS Kit version OK!"
	sleep 2
    fi
fi
if [ -e /var/db/pkg.real ];then
    echo "Fixing packages database..."
    mv /var/db/pkg /var/db/pkg.kit
    mv /var/db/pkg.real /var/db/pkg
    echo "Done!"
fi
if [ -e /var/db/pkg.kit ];then
    sleep 0
else
    cp -a /var/db/pkg /var/db/pkg.kit
fi

clear
echo "Starting UTUTO XS Kit Process....."

cp uses/package.use.ututo /usr/portage/profiles/base/package.use
cp makes.conf/make.conf.i686 /etc/make.conf
rm -rf compile.list/compile.list.all

#if [ -e compile.list/compile.list.pkg ];then
if [ "$1" = "" ];then
    PKGSX=`cat compile.list/compile.list.pkg`
    for PKGS in $PKGSX
    do
	if [ -e compile.list.virtuals/$PKGS.virt ];then
	    PKGS2="$PKGS"
	    PKGS=`cat compile.list.virtuals/$PKGS.virt`
	else
	    PKGS2=""
	fi
	echo -n "looking for $PKGS..."
	USEX=`cat /usr/portage/profiles/base/package.use | grep "/$PKGS " | cut -d "/" -f 2`
	echo -n "USE $USEX"
	mv /var/db/pkg /var/db/pkg.real
	mv /var/db/pkg.kit /var/db/pkg
	if [ "$PKGS" = "gnomex" ] || [ "$PKGS" = "kde-metax" ] || [ "$PKGS" = "lxde-metax" ] || [ "$PKGS" = "xfce4-metax" ] || [ "$PKGS" = "portagex" ] || [ "$PKGS" = "xorg-x11x" ] || [ "$PKGS" = "xorg-serverx" ];then
	    echo " deep setting"
	    PKGNAME=`emerge --nodeps -pv $PKGS | grep "ebuild  " | grep "USE=" | cut -d "/" -f 2 | cut -d " " -f 1`
	    #ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 --newuse --update --deep -pv $PKGS &> compile.list/compile.list
	    ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --deep -pv $PKGS &> compile.list/compile.list
	else
	    if [ "$PKGS" = "system" ];then
		echo " empty setting"
		PKGNAME="system"
		FECHA=`date +%Y%m%d`
		ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --empty --deep -pv $PKGS &> compile.list/compile.list
		mv /var/db/pkg /var/db/pkg.kit
		mv /var/db/pkg.real /var/db/pkg
		cat compile.list/compile.list | grep "\[ebuild " | grep -v "cracklib" | grep -v "gentoo-sources" | grep -v "linux-sources" | grep -v "virtualbox-modules" | grep -v "hardened-sources" | grep -v "openvz-sources" | grep -v "tuxonice-sources" > compile.list/compile.list.new
		mv compile.list/compile.list compile.list/compile.list.ori
		mv compile.list/compile.list.new compile.list/compile.list.$PKGNAME-$FECHA
		#mv compile.list/compile.list.new compile.list/compile.list
		echo "Done!"
		exit
	    else
		echo " diff setting"
		if [ "$PKGS2" = "" ];then
		    PKGNAME=`emerge --nodeps -pv $PKGS | grep "ebuild  " | grep "USE=" | cut -d "/" -f 2 | cut -d " " -f 1 | sed "s/::gentoo//" | sed "s/::sugar//" | sed "s/::sabayon//"`
		else
		    PKGNAME=`emerge --nodeps -pv $PKGS2 | grep "ebuild  " | grep "USE=" | cut -d "/" -f 2 | cut -d " " -f 1 | sed "s/::gentoo//" | sed "s/::sugar//" | sed "s/::sabayon//"`
		fi
		#ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 --newuse --update --deep -pv $PKGS &> compile.list/compile.list
		#ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 -pv $PKGS &> compile.list/compile.list
		ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --deep -pv $PKGS &> compile.list/compile.list
	    fi
	fi
	mv /var/db/pkg /var/db/pkg.kit
	mv /var/db/pkg.real /var/db/pkg
	cat compile.list/compile.list | grep "\[ebuild " | grep -v "cracklib" | grep -v "gentoo-sources" | grep -v "linux-sources" | grep -v "virtualbox-modules" | grep -v "hardened-sources" | grep -v "openvz-sources" | grep -v "tuxonice-sources" > compile.list/compile.list.new
	mv compile.list/compile.list compile.list/compile.list.ori
	mv compile.list/compile.list.new compile.list/compile.list.$PKGNAME
	#mv compile.list/compile.list.new compile.list/compile.list
    done
else
    PKGS=`echo $1`
    echo -n "looking for $PKGS..."
    USEX=`cat /usr/portage/profiles/base/package.use | grep "/$PKGS " | cut -d "/" -f 2`
    echo -n "USE $USEX"
    PKGNAME=`echo $1 | sed "s/=//g"`
    if [ -e scripts/compile.list.$PKGNAME ];then
	echo "Exist $PKGNAME!"
    else
	mv /var/db/pkg /var/db/pkg.real
	mv /var/db/pkg.kit /var/db/pkg
	if [ "$PKGS" = "gnomex" ] || [ "$PKGS" = "kde-metax" ] || [ "$PKGS" = "lxde-metax" ] || [ "$PKGS" = "system" ] || [ "$PKGS" = "xfce4-metax" ] || [ "$PKGS" = "portagex" ] || [ "$PKGS" = "xorg-x11x" ] || [ "$PKGS" = "xorg-serverx" ];then
	    echo " deep setting"
	    #ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 --newuse --update --deep -pv $PKGS &> compile.list/compile.list
	    ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --deep -pv $PKGS &> compile.list/compile.list
	    AMBIGUOUS=`cat compile.list/compile.list | grep "is ambiguous"`
	    NOEBUILD=`cat compile.list/compile.list | grep "no ebuilds to satisfy"`
	    SPECIAL="0"
	    if [ "$AMBIGUOUS" != "" ];then
		SPECIAL="1"
	    fi
	    if [ "$NOEBULD" != "" ];then
		SPECIAL="1"
	    fi
	    if [ "$SPECIAL" = "0" ];then
		cat compile.list/compile.list | grep "\[ebuild " | grep -v "cracklib" | grep -v "linux-sources" | grep -v "virtualbox-modules" | grep -v "gentoo-sources" | grep -v "hardened-sources" | grep -v "openvz-sources" | grep -v "tuxonice-sources" > compile.list/compile.list.new
		#mv compile.list/compile.list compile.list/compile.list.ori
		mv compile.list/compile.list.new scripts/compile.list.$PKGNAME
		#mv compile.list/compile.list.new compile.list/compile.list
	    else
		echo "Ambiguous packages found!"
		cp -a packages/i686/$PKGNAME.tbz2 tmp
		cd tmp
		bzip2recover $PKGNAME.tbz2
		bzip2 -d `ls -1 rec* | tail -n 1`
		ARCHI=`ls -1 rec* | tail -n 1`
		CATE=`cat $ARCHI  | grep "CATEGORY=" | cut -d "\"" -f 2`
		cd ..
		#ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 --newuse --update --deep -pv =$CATE/$PKGNAME &> compile.list/compile.list
		ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --deep -pv =$CATE/$PKGNAME &> compile.list/compile.list
		cat compile.list/compile.list | grep "\[ebuild " | grep -v "cracklib" | grep -v "gentoo-sources" | grep -v "linux-sources" | grep -v "virtualbox-modules" | grep -v "hardened-sources" | grep -v "openvz-sources" | grep -v "tuxonice-sources" > compile.list/compile.list.new
		#mv compile.list/compile.list compile.list/compile.list.ori
		mv compile.list/compile.list.new scripts/compile.list.$PKGNAME
		#mv compile.list/compile.list.new compile.list/compile.list
		rm -rf tmp/$PKGNAME.tbz2
		rm -rf tmp/rec00*bz2
	    fi
	else
	    echo " diff setting"
	    #PKGNAME=`emerge --nodeps -pv $PKGS | grep "ebuild  " | grep "USE=" | cut -d "/" -f 2 | cut -d " " -f 1`
	    #ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 -pv $PKGS &> compile.list/compile.list
	    ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --deep -pv $PKGS &> compile.list/compile.list
	    AMBIGUOUS=`cat compile.list/compile.list | grep "is ambiguous"`
	    NOEBUILD=`cat compile.list/compile.list | grep "no ebuilds to satisfy"`
	    SPECIAL="0"
	    if [ "$AMBIGUOUS" != "" ];then
		SPECIAL="1"
	    fi
	    if [ "$NOEBULD" != "" ];then
		SPECIAL="1"
	    fi
	    if [ "$SPECIAL" = "0" ];then
		cat compile.list/compile.list | grep "\[ebuild " | grep -v "cracklib" | grep -v "gentoo-sources" | grep -v "hardened-sources" | grep -v "linux-sources" | grep -v "virtualbox-modules" | grep -v "openvz-sources" | grep -v "tuxonice-sources" > compile.list/compile.list.new
		#mv compile.list/compile.list compile.list/compile.list.ori
		mv compile.list/compile.list.new scripts/compile.list.$PKGNAME
		#mv compile.list/compile.list.new compile.list/compile.list

		#ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 --newuse --deep --update -pv $PKGS &> compile.list/compile.list
		#cat compile.list/compile.list | grep "\[ebuild " > compile.list/compile.list.new
		#mv compile.list/compile.list compile.list/compile.list.ori
		#mv compile.list/compile.list.new compile.list/compile.list.deep.$PKGNAME
		#mv compile.list/compile.list.new compile.list/compile.list
	    else
		echo "Ambiguous packages found!"
		cp -a packages/i686/$PKGNAME.tbz2 tmp
		cd tmp
		bzip2recover $PKGNAME.tbz2
		bzip2 -d `ls -1 rec* | tail -n 1`
		ARCHI=`ls -1 rec* | tail -n 1`
		CATE=`cat $ARCHI  | grep "CATEGORY=" | cut -d "\"" -f 2`
		cd ..
		#ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 -pv =$CATE/$PKGNAME &> compile.list/compile.list
		ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --deep -pv =$CATE/$PKGNAME &> compile.list/compile.list
		cat compile.list/compile.list | grep "\[ebuild " | grep -v "cracklib" | grep -v "gentoo-sources" | grep -v "hardened-sources" | grep -v "linux-sources" | grep -v "virtualbox-modules" | grep -v "openvz-sources" | grep -v "tuxonice-sources" > compile.list/compile.list.new
		#mv compile.list/compile.list compile.list/compile.list.ori
		mv compile.list/compile.list.new scripts/compile.list.$PKGNAME
		#mv compile.list/compile.list.new compile.list/compile.list

		#ACCEPT_KEYWORDS="~x86" USE="$USEX" emerge --backtrack=30 --newuse --deep --update -pv $PKGS &> compile.list/compile.list
		#cat compile.list/compile.list | grep "\[ebuild " > compile.list/compile.list.new
		#mv compile.list/compile.list compile.list/compile.list.ori
		#mv compile.list/compile.list.new compile.list/compile.list.deep.$PKGNAME
		#mv compile.list/compile.list.new compile.list/compile.list
		rm -rf tmp/$PKGNAME.tbz2
		rm -rf tmp/rec00*bz2
	    fi
	fi
	mv /var/db/pkg /var/db/pkg.kit
	mv /var/db/pkg.real /var/db/pkg
    fi
fi
echo "Done!"
