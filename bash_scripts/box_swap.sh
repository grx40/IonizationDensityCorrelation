#You must set the initial seed in PARAMS.H to be SEED1 in order for this to work properly

SEED1=10
SEED2=90

TOTAL_Z=2
Z_START=009.20
Z_END=009.00

###########################################################################
#PART1 - RUN ./drive_zscroll_noTs and ./delta_T for both unmodified seeds #
########################################################################### 
#This first part is responsible for running 21cmFAST (without any swap) for each seed and place them in appropriate locations so that we can later move around their corresponding xH boxes
for i in $SEED1 $SEED2
do
        #run 21cmFAST for seed1
        ./drive_zscroll_noTs

        #run delta_T
        CTR=0
        for j in $Z_START $Z_END
        do
                #find xH box corresponding to the jth redshift
                fname=`ls /users/michael/documents/msi-c/21cmfast/boxes/xH* | head -$TOTAL_Z | tail -$CTR`
                ./delta_T $j  $fname
                CTR=$((CTR+1))
        done

        #lets make a folder to put the seed1 boxes and put all of them there

        mkdir /users/michael/documents/msi-c/21cmfast/boxes/boxes_for_seed$SEED1
        cp /users/michael/documents/msi-c/21cmfast/boxes/*Mpc /users/michael/documents/msi-c/21cmfast/boxes/boxes_for_seed$SEED1
	
	#tidy up the folder in preparation for the nextrun
	rm cp /users/michael/documents/msi-c/21cmfast/boxes/*Mpc
	
        #lets re-write params.h for the next seed
        sed -i -r 's/#define RANDOM_SEED (long) ($SEED1)/#define RANDOM_SEED (long) ($SEED2)/' /Users/michael/Documents/MSI-C/21cmFAST/Parameter_files/INIT_PARAMS.H

        #remake the folder
        make
done

#########################################################################
#PART2 - RUN ./delta_T again but this time for swapped xH files         #
#########################################################################

#We now run delta_T for swapped files
#the temperature file ./delta_T calls on the density box which ./delta_T  thinks is located in the /boxes folder. Therefore we if we would like to run the density of SEED1 with the ionization of SEED2, we will copy the seed 1 files back into the /boxes folder, but this time with the swapped xH boxes

#SEED1 with xH of SEED2

#copy contents of seed1 box into /boxes
cp /users/michael/documents/msi-c/21cmfast/boxes/boxes_for_seed$SEED1/*Mpc /users/michael/documents/msi-c/21cmfast/boxes/

#remove the xH files
CTR=0
for j in $Z_START $Z_END
do
	#find xH box corresponding to the jth redshift
	fname=`ls /users/michael/documents/msi-c/21cmfast/boxes/xH* | head -$TOTAL_Z | tail -$CTR`
	rm $fname
	CTR=$((CTR+1))
done

#pull the xH files from SEED2 folder into /boxes folder
CTR=0
for j in $Z_START $Z_END
do
	#find xH box corresponding to the jth redshift
	fname=`ls /users/michael/documents/msi-c/21cmfast/boxes/boxes_for_seed$SEED2/xH* | head -$TOTAL_Z | tail -$CTR`
     	mv $fname /users/michael/documents/msi-c/21cmfast/boxes/           
        CTR=$((CTR+1))
done

#rename the files

CTR=0
for j in $Z_START $Z_END
do
	#find the xH boxes we'd like to rename
	fname=` ls /users/michael/documents/msi-c/21cmfast/boxes/xH* | head -$TOTAL_Z | tail -$CTR`
	#find the corresponding name we'd like to use
	bname=`ls /users/michael/documents/msi-c/21cmfast/boxes/boxes_for_seed$SEED2/xH* | head -$TOTAL_Z | tail -$CTR`
	#strip off the path
	filename=$(basename "$bname")
	#rename the corresponding file in the /boxes folder
	mv $fname /users/michael/Documents/MSI-C/21cmFAST/Boxes/$filename
	CTR=$((CTR+1))
done


#run ./delta_T once more
CTR=0
for j in $Z_START $Z_END
do
	#find xH box corresponding to the jth redshift
	fname=`ls /users/michael/documents/msi-c/21cmfast/boxes/xH* | head -$TOTAL_Z | tail -$CTR`
	./delta_T $j  $fname
	CTR=$((CTR+1))
done
