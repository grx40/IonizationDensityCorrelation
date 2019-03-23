#You must set the initial seed in PARAMS.H to be SEED1 in order for this to work properly

SEED1=10
SEED2=90

TOTAL_Z=2
Z_START=009.20
Z_END=009.00

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

        #lets re-write params.h for the next seed
        sed -i -r 's/#define RANDOM_SEED (long) ($SEED1)/#define RANDOM_SEED (long) ($SEED2)/' /Users/michael/Documents/MSI-C/21cmFAST/Parameter_files/INIT_PARAMS.H

        #remake the folder
        make
done

