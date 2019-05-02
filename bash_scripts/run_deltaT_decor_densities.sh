###########################################################################################
# This script cleans up /boxes folder, runs 21cmFAST for our choice of redshift           #
# then runs ./phase_shift.py which phase shifts the data and then calls                   #
# ./delta_T to run the temperature file. We then pass that to the power spectrum script   #
###########################################################################################


#Define some constants
export SIGMA1=0.0
export SIGMA2=0.5
export SIGMA3=0.75
export SIGMA4=0.99
export SIGN=0

PROGRAM_PATH="/users/michael/documents/msi-c/21cmFAST/programs/"

export Z_START=009.00
export Z_END=009.40
export Z_STEP=0.2

echo cleanup on aisle Mpc
rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/*Mpc
rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxes/*
rmdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxes/


for j in $SIGMA1 $SIGMA2 $SIGMA3 $SIGMA4
do
	#echo deleting /users/michael/documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensitiesSigma"$j"/
	rm /users/michael/documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensitiesSigma"$j"/*
	rmdir /users/michael/documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensitiesSigma"$j"/
done

pushd $PROGRAM_PATH
make


##################
#  Run 21cmFAST  #
##################


./drive_zscroll_noTs
#run temperature
#do not run this if the simulation has already been run

CTR=0
for i in $(seq $Z_START $Z_STEP $Z_END)
do
	CTR=$((CTR+1))
	fname=`ls /users/michael/documents/MSI-C/21cmFAST/Boxes/xH* | head -$CTR | tail -1`
	filename=$(basename "$fname")
	echo Running temperature for "$filename"
	./delta_T $i ../Boxes/"$filename"
done


#make a directory for the unaltered files
mkdir /users/michael/documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxes

#copy the unaltered densities and temperatures into a folder
cp /users/michael/documents/MSI-C/21cmFAST/Boxes/delta_T* /users/michael/documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxes/
cp /users/michael/documents/MSI-C/21cmFAST/Boxes/updated_smoothed_deltax* /users/michael/documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxes/

#################################################
# Call on ./phase_shift.py to shift density data #
#################################################



/Users/michael/research/densityioncorrelations/powerspectrumanalyses/phaseshift_density.py



#####################################################
#  Run the temperature file for each sigma across z  #
#####################################################


rm /users/michael/documents/MSI-C/21cmFAST/Boxes/updated_smoothed_deltax*
rm /users/michael/documents/MSI-C/21cmFAST/Boxes/delta_T*



for j in $SIGMA1 $SIGMA2 $SIGMA3 $SIGMA4
do
	cp /users/michael/Documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensitiesSigma"$j"/updated_smoothed_deltax* /users/michael/Documents/MSI-C/21cmFAST/Boxes/
	echo copied files from DecorrelatedDensitiesSigma"$j"	 
	CTR=0
	for i in $(seq $Z_START $Z_STEP $Z_END)
	do
		CTR=$((CTR+1))
		fname=` ls /users/michael/documents/msi-c/21cmFAST/boxes/xH* | head -$CTR | tail -1`
		filename=$(basename "$fname")
		echo Running temperature for $filename
		./delta_T $i ../Boxes/"$filename"
	done
	
	cp /users/michael/documents/MSI-C/21cmFAST/Boxes/delta_T* /users/michael/documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensitiesSigma"$j"/
	rm /users/michael/documents/MSI-C/21cmFAST/Boxes/delta_T*
	rm /users/michael/documents/MSI-C/21cmFAST/Boxes/updated_smoothed_deltax*

done




#Run power spectrum from bash script?
 

