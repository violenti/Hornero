#!/bin/bash

echo -n "Processing..... please wait!! -> "
SERIAL=`date | sed "s/lun //" | sed "s/mar //" | sed "s/mie //" | sed "s/jue //" | sed "s/vie //" | sed "s/sab //" | sed "s/dom //" | sed "s/ /_/g" | sed "s/__/_/g"`
echo $SERIAL

cp -a /var/db/pkg /var/db/pkg.$SERIAL
# mv /var/db/pkg.kit /var/db/pkg.kit.$SERIAL
cp -a /var/db/pkg.kit /var/db/pkg.kit.$SERIAL
# cp -a /var/db/pkg /var/db/pkg.kit
mv compile.list compile.list.$SERIAL
mkdir compile.list
cp -a compile.list.$SERIAL/compile.list.pkg compile.list
mv packages packages.$SERIAL
mv compile.list.replace/replace.pkg compile.list.replace/replace.pkg.$SERIAL
touch compile.list.replace/replace.pkg
mkdir packages
mv scripts scripts.$SERIAL
mkdir scripts
mv scripts.$SERIAL/scripts.process scripts
mv sh sh.$SERIAL
mkdir sh
cp -a uses uses.$SERIAL
rm -rf sh.log

echo "Done!"
