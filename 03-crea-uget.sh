#!/bin/bash

cp uses/package.use.ututo /usr/portage/profiles/base/package.use
cp makes.conf/make.conf.i686 /etc/make.conf
cd tmp
rm -rf *
cd ..

ls -1 scripts/compile.list.* > tmp/listado-paquetes-uget.txt
echo "Log start" > sh.log

while read PKG
do
   PKGSH=`echo $PKG | sed "s/scripts\/compile.list.//g"`
   if [ ! -e sh/$PKGSH.sh ];then
    echo "Processing $PKGSH..."
    cp -a packages/i686/$PKGSH.tbz2 tmp
    cd tmp
    bzip2recover $PKGSH.tbz2
    bzip2 -d `ls -1 rec* | tail -n 1`
    ARCHI=`ls -1 rec* | tail -n 1`
    DESC=`cat $ARCHI  | grep "DESCRIPTION=" | cut -d "\"" -f 2`
    LICE=`cat $ARCHI  | grep "LICENSE=" | cut -d "\"" -f 2`
    CATE=`cat $ARCHI  | grep "CATEGORY=" | cut -d "\"" -f 2`
    PN=`cat $ARCHI  | grep "PN=" | cut -d "\"" -f 2`
    cd ..
    rm -rf tmp/$PKGSH.tbz2
    rm -rf tmp/rec00*bz2
    touch tmp/$PKGSH.pkg1
    touch tmp/$PKGSH.pkg2
    echo "DESCRIPTION=\"$DESC\"" >> tmp/$PKGSH.pkg1
    echo "LICENSE=\"$LICE\"" >> tmp/$PKGSH.pkg1
    echo "CATEGORY=\"$CATE\"" >> tmp/$PKGSH.pkg1
    while read EBUILD
    do
	PKGNAME=`echo $EBUILD | cut -d "/" -f 2 | cut -d " " -f 1 | cut -d ":" -f 1`
	#echo "Adding $PKGNAME to $PKGSH2 ($PKG)..."
	ISOPENRC=`echo $PKGNAME | grep "openrc-"`
	cat scripts/scripts.process/find.pkg | sed "s/XXPKGNAMEXX/$PKGNAME/g" >> tmp/$PKGSH.pkg1
	cat scripts/scripts.process/post.pkg | sed "s/XXPKGNAMEXX/$PKGNAME/g" >> tmp/$PKGSH.pkg2
	if [ -e packages/i686/$PKGNAME.tbz2 ];then
	    cp -a packages/i686/$PKGNAME.tbz2 tmp
	    cd tmp
	    bzip2recover $PKGNAME.tbz2
	    bzip2 -d `ls -1 rec* | tail -n 1`
	    ARCHI=`ls -1 rec* | tail -n 1`
	    PN=`cat $ARCHI | grep "PN=" | grep -v "MY_PN=" | cut -d "\"" -f 2`
	    cd ..
	    rm -rf tmp/$PKGNAME.tbz2
	    rm -rf tmp/rec00*bz2
	    cat scripts/scripts.process/$PN.post | sed "s/XXPKGNAMEXX/$PKGNAME/g" >> tmp/$PKGSH.pkg2
	    echo "tbz2 file $PKGNAME ($PN) exist! in compiled" >> sh.log
	else
	    cp `find packages.*/$PKGNAME.tbz2` packages
	    if [ -e packages/$PKGNAME.tbz2 ];then
		sleep 0
	    else
		cp `find packages.*/i686/$PKGNAME.tbz2` packages
	    fi
	    if [ -e packages/$PKGNAME.tbz2 ];then
		cp -a packages/$PKGNAME.tbz2 tmp
		cd tmp
	        bzip2recover $PKGNAME.tbz2
	        bzip2 -d `ls -1 rec* | tail -n 1`
		ARCHI=`ls -1 rec* | tail -n 1`
		PN=`cat $ARCHI | grep "PN=" | grep -v "MY_PN=" | cut -d "\"" -f 2`
		cd ..
		rm -rf tmp/$PKGNAME.tbz2
		rm -rf tmp/rec00*bz2
		cat scripts/scripts.process/$PN.post | sed "s/XXPKGNAMEXX/$PKGNAME/g" >> tmp/$PKGSH.pkg2
		#rm -rf packages/$PKGNAME.tbz2
		echo "tbz2 file $PKGNAME ($PN) exist! in local" >> sh.log
	    else
		if [ -e packages/$PKGNAME.tbz2 ];then
		    sleep 0
		else
		    wget packages.ututo.org/utiles/00Testing/i686/$PKGNAME.tbz2
		    if [ ! -e $PKGNAME.tbz2 ];then
			wget packages.ututo.org/utiles/00Testing/i686/$PKGNAME.tbz2
		fi
		    mv $PKGNAME.tbz2 packages
		fi
		
                    if [ -e packages/$PKGNAME.tbz2 ];then
		    cp -a packages/$PKGNAME.tbz2 tmp
		    cd tmp
		    bzip2recover $PKGNAME.tbz2
		    bzip2 -d `ls -1 rec* | tail -n 1`
		    ARCHI=`ls -1 rec* | tail -n 1`
		    PN=`cat $ARCHI | grep "PN=" | grep -v "MY_PN=" | cut -d "\"" -f 2`
		    cd ..
		    rm -rf tmp/$PKGNAME.tbz2
		    rm -rf tmp/rec00*bz2
		    cat scripts/scripts.process/$PN.post | sed "s/XXPKGNAMEXX/$PKGNAME/g" >> tmp/$PKGSH.pkg2
		    #rm -rf packages/$PKGNAME.tbz2
		    echo "tbz2 file $PKGNAME ($PN) exist! in web" >> sh.log
		else
		    echo "tbz2 file $PKGNAME dont exist! in compiled/local/web" >> sh.log
		fi
	    fi
	    EXISTE=`find /var/db/pkg -type f -name '*.ebuild' -print | sed -e "s/.ebuild//" | grep "$PKGNAME" | cut -d "/" -f 7`
	    if [ "$EXISTE" != "$PKGNAME" ];then
		echo "tbz2 file $PKGNAME dont exist!"
		echo "tbz2 file $PKGNAME dont exist!" >> sh.log
	    fi
	fi
	if [ "$ISOPENRC" != "" ];then
	    PKGNAME=`echo $PKGNAME | sed "s/openrc-/openrc-ututo-/g"`
	    cat scripts/scripts.process/find.pkg | sed "s/XXPKGNAMEXX/$PKGNAME/g" >> tmp/$PKGSH.pkg1
	    cat scripts/scripts.process/post.pkg | sed "s/XXPKGNAMEXX/$PKGNAME/g" >> tmp/$PKGSH.pkg2
	fi
    done < $PKG
    cat tmp/$PKGSH.pkg2 >> tmp/$PKGSH.pkg1
    rm -rf tmp/$PKGSH.pkg2
    cat scripts/scripts.process/fin.pkg >> tmp/$PKGSH.pkg1
    mv tmp/$PKGSH.pkg1 sh/$PKGSH.sh
    sed -i 's/::gentoo//' sh/$PKGSH.sh
   else
	echo "Package sh/$PKGSH.sh exist!"
   fi
done < tmp/listado-paquetes-uget.txt
#rm -rf tmp/listado-paquetes-uget.txt
sed -i 's/::gentoo//' sh/*.sh
sed -i 's/::sugar//' sh/*.sh
sed -i 's/::sabayon//' sh/*.sh
echo "Log stop" >> sh.log
