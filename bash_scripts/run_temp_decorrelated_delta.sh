###########################################################################################
# This script cleans up /boxes folder, runs 21cmFAST for our choice of redshift           #
# then runs ./phase_shift.py which phase shifts the data and then calls                   #
# ./delta_T to run the temperature file. We then pass that to the power spectrum script   #
###########################################################################################


#Define some constants

#PROGRAM_PATH="/users/michael/documents/msi-c/21cmFAST/programs"

Z_START=005.00
Z_END=015.80
Z_STEP=0.2

#pushd $PROGRAM_PATH

#cleanup the folder before beginning
#rm users/michael/docuemnts/msi-c/21cmFAST/boxes/*Mpc

#make


##################
#  Run 21cmFAST  #
##################


./drive_zscroll_noTs



#################################################
# Call on ./phase_shift.py to shift all the data #
#################################################


/users/michael/documents/research/PowerSpectrum21cmFAST/phase_shift.py
 


##################################################
#  Run the temperature file for all redshifts   #
#################################################

CTR=0
for i in $(seq $Z_START $Z_STEP $Z_END)
do
	CTR=$((CTR+1))
	fname=` ls /users/michael/documents/msi-c/21cmFAST/boxes/xH* | head -$CTR | tail -1`
	filename=$(basename "$fname")
	echo Running temperature for $filename
	./delta_T $i ../Boxes/"$filename"
done


#Run power spectrum from bash script?
 

