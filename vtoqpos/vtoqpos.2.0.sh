#!/bin/bash
######################################################
#This script will convert POSCAR into POS.q CELL.q
######################################################
#Author: Meng Wu
#Date: Jan 28, 2016
######################################################
#Version 2.0
######################################################
QPOSfile="POS.q"
QCELLfile="CELL.q"
if [ $# == 0 ]; then
    VPOSfile="POSCAR"
else
    VPOSfile=$1
fi

if [ ! -f $VPOSfile ]; then
    echo "Error: Cannot find $VPOSfile!"
    exit 1
fi
echo "=============================================="
echo "Reading VASP pos/cell info from $VPOSfile"
echo "=============================================="
######################################################
#Clearance
rm -rf $QPOSfile
rm -rf $QCELLfile
#Header
echo "CELL_PARAMETERS angstrom" > $QCELLfile
echo "ATOMIC_POSITIONS crystal" > $QPOSfile
######################################################
#CELL parameters
sed -n '3,5 p' $VPOSfile >> $QCELLfile
######################################################
#Elements and number of atoms
NumofElements=$(sed -n '6 p' $VPOSfile | awk '{print NF}')
######################################################
#V2.0: Some POSCAR contain `selective dynamics', some doesn't.
linetoread=$(grep -in 'direct' $VPOSfile | awk -F ":" '{print $1+1}')
echo "startling line of atomic positions: $linetoread"

for ((i=1;i<=$NumofElements;i++))
do
    ElementName=$( sed -n '6 p' $VPOSfile | awk '{print $('${i}')}' )
    ElementNum=$( sed -n '7 p' $VPOSfile | awk '{print $('${i}')}' )
    for ((j=1;j<=$ElementNum;j++))
    do
        #a=1
        echo $ElementName $(sed -n "$linetoread p" $VPOSfile) | awk '{printf("%s   %10.9f  %10.9f  %10.9f   1  1  1\n",$1,$2,$3,$4)}' >> $QPOSfile
        linetoread=$(echo "$linetoread + 1" | bc )
    done
done
######################################################
echo "Done!"
echo "=============================================="
