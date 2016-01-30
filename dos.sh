#!/bin/bash
if [ $# -ne 0 ]; then
	echo "Usage: split_dos"
	exit 2
fi

DIR=DOS
if [ -d "./$DIR" ]; then
	echo "directory $DIR exists, now we will clear it"
	rm -f ./${DIR}/*
else 
	echo "directory $DIR does not exist,we will create one"
	mkdir ${DIR}
fi
# Script to split the DOSCAR file into the atomic
# projections labeled by atom number
dosfile=DOSCAR
outfile=OUTCAR
infile=INCAR

# Token for splitting the files
high=$(sed -n '6 p' $dosfile | awk '{print $1}')
echo "Highest energy = ${high} eV"
# Number of points
numofpoints=$(sed -n '6 p' $dosfile | awk '{print $3}')
echo "Number of points = ${numofpoints}"
# Number of atoms
numofatoms=$(sed -n '1 p' $dosfile | awk '{print $1}')
echo "Number of atoms = ${numofatoms}"
# Get the Fermi level if the OUTCAR file is present,
# else we set it to zero.
if [ -a $outfile ]; then
    echo "The" $outfile "exists, we use it to get the Fermi level,"
    echo "the RWIGS tag and the number of spins."
    efermi=$(grep "E-fermi" $outfile | tail -1 | awk '{print $3}')
    echo "Fermi level:" $efermi
    nspin=$(grep "ISPIN" $infile | tail -1 | awk '{print $3}')
    echo "ISPIN = $nspin"
    if [ $nspin -eq 2 ]; then
	echo "Spin polarized calculation"
    else
	echo "Unpolarized calculation"
    fi
#atom-projected density of states
    lorbit=$(grep "LORBIT" $infile | tail -1 | awk '{print $3}')
    echo "LORBIT = ${lorbit}"
    if [ $lorbit -ge 10 ]; then
        echo "LORBIT > 10"
	atoms=1
    else
    	atoms=0
    fi
#spin-orbital-coupling
    lsorbit=$(grep "LSORBIT" $infile | tail -1 | awk '{print $3}')
    echo "LSORBIT = ${lsorbit}"
    if [ "$lsorbit" == ".TRUE." ]; then
    	echo "Spin-orbital-coupling switched on"
    else
	echo "Spin-orbital-coupling switched off"
    fi
fi
##########################################################
if [ "$atoms" -eq 0 ]; then 
	numofatoms=0
fi
#########################################################3
for ((i = 0 ; i <= numofatoms ; i++)); do
    	startline=$((7+$i*$numofpoints+$i))
	endline=$((5+($i+1)*(numofpoints+1)))
	if [ "$lsorbit" == ".TRUE." ]; then	
		#echo "DOS$i startline =  $startline, endline =  $endline"
	# Total DOS
		if [ $i -eq 0 ]; then
		    echo "total density of states"
		    sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi', $2, $3 }' > ${DIR}/DOS$i		 
	    	else
	#noncollinear calculation with d electrons	
 		echo "density of states projected on ${i}th atom"
	# Atomic projected DOS
#		echo ' '| awk '{printf "\n"}' >> ${DIR}/DOS$i
		echo "Energy	         s	        py	       pz	      px	      dxy            dyz            dz2            dxz            dx2-y2 " | cat >> ${DIR}/DOS$i
		sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi', $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37 }' >> ${DIR}/DOS$i
		echo "Energy	         s	        py	       pz	      px	      dxy            dyz            dz2            dxz            dx2-y2 " | cat >> ${DIR}/DOS${i}_total
		sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi',$2,$6,$10,$14,$18,$22,$26,$30,$34}' >> ${DIR}/DOS${i}_total
		echo "Energy	         s	        py	       pz	      px	      dxy            dyz            dz2            dxz            dx2-y2 " | cat >> ${DIR}/DOS${i}_mx
		sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi',$3,$7,$11,$15,$19,$23,$27,$31,$35}' >> ${DIR}/DOS${i}_mx
		echo "Energy	         s	        py	       pz	      px	      dxy            dyz            dz2            dxz            dx2-y2 " | cat >> ${DIR}/DOS${i}_my
		sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi',$4,$8,$12,$16,$20,$24,$28,$32,$36}' >> ${DIR}/DOS${i}_my
		echo "Energy	         s	        py	       pz	      px	      dxy            dyz            dz2            dxz            dx2-y2 " | cat >> ${DIR}/DOS${i}_mz
		sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi',$5,$9,$13,$17,$21,$25,$29,$33,$37}' >> ${DIR}/DOS${i}_mz
		fi
	else
 #########################################################################
 #no spin-orbital coupling
		if [ $nspin -eq 2 ]; then
			#spin-polarized
			# Total DOS
			#echo "I am here!from ${startline} to ${endline}"
			if [ $i -eq 0 ]; then
		echo "Energy	         Up	        Down           Integrated_Up   Integrated_Down" | cat >> ${DIR}/DOS${i}
			       	echo "total density of states"
				sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi',$2,-$3,$4,-$5 }' >> ${DIR}/DOS${i}	
		 	else
 				echo "density of states projected on ${i}th atom"
			# Atomic projected DOS
		echo "Energy	         s_Up	        py_Up	       pz_Up	      px_Up	     dxy_Up         dyz_Up         dz2_Up        dxz_Up          dx2-y2_Up      s_Down           py_Down       pz_Down       px_Down       dxy_Down        dyz_Down        dz2_Down       dxz_Down      dx2-y2_Down" | cat >> ${DIR}/DOS${i}
			sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi', $2,-$3,$4,-$5,$6,-$7,$8,-$9,$10,-$11,$12,-$13,$14,-$15,$16,-$17,$18,-$19 }' >> ${DIR}/DOS$i
			fi
		else
			#non-spin-polarized
			# Total DOS
			if [ $i -eq 0 ]; then
			       	echo "total density of states"
		echo "Energy	        density" | cat >> ${DIR}/DOS${i}

				sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi',$2,$3 }' >> ${DIR}/DOS$i
		 	else
 				echo "density of states projected on ${i}th atom"
			# Atomic projected DOS
		echo "Energy	         s	        py	       pz	      px	      dxy            dyz            dz2            dxz            dx2-y2 " | cat >> ${DIR}/DOS${i}
		sed -n ''$startline','$endline' p' $dosfile | awk '{printf "%14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f %14.10f \n", $1+(-1)*'$efermi', $2,$3,$4,$5,$6,$7,$8,$9,$10 }' >> ${DIR}/DOS${i}
			fi
		fi

	fi
done
