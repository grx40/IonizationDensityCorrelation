
PROGRAM_PATH="/users/michael/documents/msi-c/21cmfast/programs"

SEED1=200
SEED2=350
echo NotTesting

#TOTAL_Z=2
Z_START=005.00
Z_END=015.80
Z_STEP=0.2

COUNTER=1

pushd $PROGRAM_PATH

#cleanup the folder before beginning
rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/*Mpc

#set the initial seed to be seed1 defined above
sed -i -r 's/#define RANDOM_SEED.*/#define RANDOM_SEED (long) ('"$SEED1"')/' /Users/michael/Documents/MSI-C/21cmFAST/Parameter_files/INIT_PARAMS.H

#remake the folder
make




###########################################################################
#PART1 - RUN ./drive_zscroll_noTs and ./delta_T for both unmodified seeds #
###########################################################################


#This first part is responsible for running 21cmFAST (without any swap) for each seed and place them in appropriate locations so that we can later move around their corresponding xH boxes
for i in $SEED1 $SEED2
do
	
        #run 21cmFAST for seed1
        ./drive_zscroll_noTs
	echo 21cmFAST is done, now running delta_T
	
        #run delta_T
        CTR=0
        for j in $(seq $Z_START $Z_STEP $Z_END) 
        do
		CTR=$((CTR+1))
                #find xH box corresponding to the jth redshift
                fname=`ls /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH* | head -$CTR | tail -1`
        	echo starting with xH box: $fname
		filename=$(basename "$fname")		  
		./delta_T $j ../Boxes/"$filename"
        done

        #lets make a folder to put the seed1 boxes and put all of them there

	echo Making a directory for seed $i
        mkdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/boxes_for_seed"$i"
        cp /users/michael/Documents/MSI-C/21cmFAST/Boxes/*Mpc /users/michael/Documents/MSI-C/21cmFAST/Boxes/boxes_for_seed"$i"
	
	echo copied files
	#tidy up the folder in preparation for the nextrun
	rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/*Mpc
	echo removing folder
        
	#lets re-write params.h for the next seed
        if [ $COUNTER == 1 ]
	then
		sed -i -r 's/#define RANDOM_SEED (long) ('"$SEED1"')/#define RANDOM_SEED (long) ('"$SEED2"')/' /Users/michael/Documents/MSI-C/21cmFAST/Parameter_files/INIT_PARAMS.H

	
		#remake the folder
		make
		echo remade the folder
		COUNTER=$((COUNTER+1))
	fi

done

#########################################################################
#PART2 - RUN ./delta_T again but this time for swapped xH files         #
#########################################################################

#We now run delta_T for swapped files
#the temperature file ./delta_T calls on the density box which ./delta_T  thinks is located in the /boxes folder. Therefore we if we would like to run the density of SEED1 with the ionization of SEED2, we will copy the seed 1 files back into the /boxes folder, but this time with the swapped xH boxes

#SEED1 with xH of SEED2

#echo copying seed1 into boxes
#copy contents of seed1 box into /boxes
cp /users/michael/Documents/MSI-C/21cmFAST/Boxes/boxes_for_seed"$SEED1"/*Mpc /users/michael/Documents/MSI-C/21cmFAST/Boxes/


#remove the xH files
echo removing xH files from /boxes
#CTR=0
#for j in $Z_START $Z_END
#do
#	CTR=$((CTR+1))
#	#find xH box corresponding to the jth redshift
#	fname=`ls /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH* | head -$CTR | tail -1`
#	rm $fname
#done
rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH*


#pull the xH files from SEED2 folder into /boxes folder
echo copying files from "$SEED2" into /boxes
#CTR=0
#for j in $Z_START $Z_END
#do
#	CTR=$((CTR+1))
#	#find xH box corresponding to the jth redshift
#	fname=`ls /users/michael/Documents/MSI-C/21cmFAST/Boxes/boxes_for_seed"$SEED2"/xH* | head -$CTR | tail -1`
#	cp $fname /users/michael/Documents/MSI-C/21cmFAST/Boxes/
#        
#done
cp /users/michael/Documents/MSI-C/21cmFAST/Boxes/boxes_for_seed"$SEED2"/xH* /users/michael/Documents/MSI-C/21cmFAST/Boxes/



#rename the files

echo renaming the files
CTR=0
for j in $(seq $Z_START $Z_STEP $Z_END)
do
	CTR=$((CTR+1))
	#find the xH boxes we'd like to be renamed
	fname=` ls /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH* | head -$CTR | tail -1`
	filename=$(basename "$fname")
	#find the corresponding name we'd like to use
	bname=`ls /users/michael/documents/MSI-C/21cmFAST/Boxes/boxes_for_seed"$SEED1"/xH* | head -$CTR | tail -1`
	#strip off the path
	bilename=$(basename "$bname")
	#rename the corresponding file in the /boxes folder
	mv /users/michael/Documents/MSI-C/21cmFAST/Boxes/"$filename" /users/michael/Documents/MSI-C/21cmFAST/Boxes/"$bilename"
done



#run ./delta_T once more

echo running delta_T with the swapped boxes
CTR=0
for j in $(seq $Z_START $Z_STEP $Z_END)
do
	CTR=$((CTR+1))
	echo $CTR
	#find xH box corresponding to the jth redshift
	fname=`ls /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH* | head -$CTR | tail -1`
	echo $fname
	filename=$(basename "$fname")
	./delta_T $j ../Boxes/"$filename"
	
done

popd > /dev/null
