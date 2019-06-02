##########################################################################################
# This script cleans up /boxes folder, runs 21cmFAST for our choice of redshift           #
# then runs ./phase_shift.py which phase shifts the data and then calls                   #
# ./delta_T to run the temperature file. We then pass that to the power spectrum script   #
###########################################################################################


#Define some constants
export SIGMA1=0.0
export SIGMA2=0.5
export SIGMA3=0.75
export SIGMA4=0.99
export SIGMA5=1.25
export SIGMA6=1.5
export SIGMA7=1.75
export SIGMA8=2

PROGRAM_PAT="/users/michael/documents/msi-c/21cmFAST/programs/"

export Z_START=009.00
export Z_END=009.40
export Z_STEP=0.2

echo cleanup on aisle Mpc
rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/*Mpc
rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNoGaussianities/*
rmdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNoGaussianities/
rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNegativeNoGaussianities/*
rmdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNegativeNoGaussianities/
mkdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNoGaussianities/
mkdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNegativeNoGaussianities/

pushd $PROGRAM_PATH

##########################################
#       Run Unaltered Simulation        #
#########################################
rm ./init.c
cp ./original_program_files/init.c ./
make
./init
./drive_zscroll_noTs
CTR=0
for i in $(seq $Z_START $Z_STEP $Z_END)
do
	CTR=$((CTR+1))
	fname=` ls /users/michael/documents/msi-c/21cmFAST/boxes/xH* | head -$CTR | tail -1`
	filename=$(basename "$fname")
	echo Running temperature for $filename
	./delta_T $i ../Boxes/"$filename"
done
cp ../Boxes/*Mpc ../Boxes/OriginalTemperatureBoxesNoGaussianities/
rm ../Boxes/*Mpc


##########################################
#       Run Sign Swapped Simulation      #
#########################################
rm ./init.c
cp ./modified_program_files/init_signswap.c ./
mv ./init_signswap.c ./init.c
make
./init
./drive_zscroll_noTs
rm /users/michael/documents/MSI-C/21cmFAST/Boxes/xH* 
cp /users/michael/documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNoGaussianities/xH* /users/michael/documents/MSI-C/21cmFAST/Boxes/
CTR=0
for i in $(seq $Z_START $Z_STEP $Z_END) 
do      
        CTR=$((CTR+1))
        fname=` ls /users/michael/documents/msi-c/21cmFAST/boxes/xH* | head -$CTR | tail -1`
        filename=$(basename "$fname")
        echo Running temperature for $filename
        ./delta_T $i ../Boxes/"$filename"
done
cp ../Boxes/*Mpc ../Boxes/OriginalTemperatureBoxesNegativeNoGaussianities/
rm ../Boxes/*Mpc
rm ./init.c
cp ./modified_program_files/init_phaseshift.c ./
mv ./init_phaseshift.c ./init.c
make



for k in 1 -1
do
	for s in $SIGMA1 $SIGMA2 $SIGMA3 $SIGMA4
	do

		rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensities_k"$k"_s"$s"/*
		rmdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensities_k"$k"_s"$s"/
		./init $k $s
		./drive_zscroll_noTs
		rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/xH*
		cp /users/michael/Documents/MSI-C/21cmFAST/Boxes/OriginalTemperatureBoxesNoGaussianities/xH* ../Boxes/
		################################
		#        Run temperature       #
		################################
		CTR=0
                for i in $(seq $Z_START $Z_STEP $Z_END)
                do
                        CTR=$((CTR+1))
                        fname=` ls /users/michael/documents/msi-c/21cmFAST/boxes/xH* | head -$CTR | tail -1`
                        filename=$(basename "$fname")
                        echo Running temperature for $filename
                        ./delta_T $i ../Boxes/"$filename"
                done
		mkdir /users/michael/Documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensities_k"$k"_s"$s"
                cp /users/michael/Documents/MSI-C/21cmFAST/Boxes/*Mpc /users/michael/Documents/MSI-C/21cmFAST/Boxes/DecorrelatedDensities_k"$k"_s"$s"
		rm /users/michael/Documents/MSI-C/21cmFAST/Boxes/*Mpc
		
	done

done



