#!/bin/bash
######################################################
#This script will convert POSCAR into POS.q CELL.q
######################################################
#Author: Meng Wu
#Date: Aug 30, 2015
######################################################
#Version 1.0
######################################################
QPOSfile="POS.q"
QCELLfile="CELL.q"
VPOSfile="POSCAR"
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
linetoread=10
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
