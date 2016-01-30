#!/bin/bash
################################################
#This script will sum specified DOS
################################################
JobName="S"
if [ $JobName == "Mo" ];then
   startindex=1
   endindex=8
   DOSoutput="DOS_Mo"
fi
if [ $JobName == "W" ];then
   startindex=9
   endindex=16
   DOSoutput="DOS_W"
fi
if [ $JobName == "S" ];then
   startindex=17
   endindex=48
   DOSoutput="DOS_S"
fi

###############################################
SumSeq=$(seq -s ' ' $startindex $endindex)
#Prepare DOSseq
DOSseq=" "
DOStemp1="DOS.temp1"
DOStemp2="DOS.temp2"
EnergyFile="EnergyRange"
startflag="0"
################################################
rm -rf $DOSoutput
rm -rf $DOStemp1
rm -rf $DOStemp2
rm -rf $EnergyFile
################################################
for i in $SumSeq
do
echo "DOS$i"
#DOSseq+="DOS$i "
sed '/^Energy/d' "DOS0" | awk '{print $1}' > $EnergyFile

if [ $startflag -eq "0" ]; then
   sed '/^Energy/d' "DOS$i" | awk '{$1="";print}' > $DOSoutput 
   startflag="1"
else
   sed '/^Energy/d' "DOS$i" | awk '{$1="";print}' > $DOStemp1
   paste $DOStemp1 $DOSoutput | awk '{printf("%11.10f %11.10f %11.10f %11.10f %11.10f %11.10f %11.10f %11.10f %11.10f \n",$1+$10,$2+$11,$3+$12,$4+$13,$5+$14,$6+$15,$7+$16,$8+$17,$9+$18)}' > $DOStemp2
   mv $DOStemp2 $DOSoutput
fi
#awk '{$1=""; $2=""; sub("  ", " "); print}' input_filename > output_filename
done
mv $DOSoutput $DOStemp1
paste $EnergyFile $DOStemp1 > $DOSoutput
#echo $DOSseq
#echo 
#sed  '/^Energy/d' $DOSseq
