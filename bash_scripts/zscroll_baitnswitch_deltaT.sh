hey hey! 3




SEED=90
DIR="Boxes_for_seed_$SEED"
echo Running, moving on with the script for seed $SEED

#directory of the files we're disguising as our own simulation
BENCH="boxes_seed_10"


#wait until the xH box is made
DUM=2
while [ $DUM==2 ]
do
if [ -e /users/michael/documents/msi-c/21cmFAST/boxes/xH* ]
then
echo file is made
fname=`ls /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH* | head -1 | tail -1`
break
fi

done
echo out of while loop

#make a directory for the box we're going to move
mkdir /users/michael/documents/msi-c/21cmfast/boxes/$DIR
mv $fname /users/Michael/Documents/MSI-C/21cmFAST/Boxes/$DIR
filename=$(basename "$fname")
echo made the directory

#locate the directory and disguise the bait
bait=` ls /users/michael/documents/MSI-C/21cmFAST/Boxes/$BENCH/xH* | head -1 | tail -1`
mv $bait /users/michael/documents/MSI-C/21cmFAST/Boxes/$BENCH/$filename

echo making the switch

#switch
mv /users/michael/documents/MSI-C/21cmFAST/Boxes/$BENCH/$filename /users/michael/documents/MSI-C/21cmFAST/Boxes
echo made the switch
#run ./Delta_T
#for i in 1 2
#do
#        fname=`ls /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH* | head -$i | tail -1`
#        echo $fname
#        ./delta_T  009.00 $fname
#done

######## THIS IS A TEST COMMENT

#write a new random seed and remake the folder
#sed -i -r 's/#define RANDOM_SEED (long) (1)/#define RANDOM_SEED (long) (321)/' /Users/michael/Documents/MSI-C/21cmFAST/Parameter_files/INIT_PARAMS.H

