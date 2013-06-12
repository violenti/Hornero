#!/bin/bash
cd compile.list
LISTA=`ls -1 | grep -v '.pkg' | grep -v '.ori'`
for X in $LISTA
do
    for X2 in `cat ../compile.list.replace/replace.pkg | cut -d ']' -f 2 | sed "s/ //g" | sed "s/\[/|/g"`
    do
	CAT=`echo $X2 | cut -d '/' -f 1`
	ORI=`echo $X2 | cut -d '/' -f 2 | cut -d '|' -f 1`
	RPL=`echo $X2 | cut -d '|' -f 2`
	echo " $X: $CAT/$ORI --> $CAT/$RPL"
	sed -i "s/$ORI/$RPL/g" "$X"
    done
done
cd ..