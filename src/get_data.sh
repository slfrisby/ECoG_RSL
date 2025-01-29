#!/bin/bash

# gets ready-preprocessed data from a previous ECoG project and moves it to the derivatives folder. 

# for each participant
for s in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 17 20 21 22; do

# create output directory
mkdir -p /group/mlr-lab/Saskia/ECoG_RSL/derivatives/data/sub-$s/

# copy decibel-normalised power, phase, and voltage data across
cp /group/mlr-lab/Saskia/ECoG_LASSO/derivatives/wavelet/sub-$s/dBpower.mat /group/mlr-lab/Saskia/ECoG_RSL/derivatives/data/sub-$s/dBpower.mat
cp /group/mlr-lab/Saskia/ECoG_LASSO/derivatives/wavelet/sub-$s/phase.mat /group/mlr-lab/Saskia/ECoG_RSL/derivatives/data/sub-$s/phase.mat
cp /group/mlr-lab/Saskia/ECoG_LASSO/derivatives/wavelet/sub-$s/voltage.mat /group/mlr-lab/Saskia/ECoG_RSL/derivatives/data/sub-$s/voltage.mat

done

# copy MNI coordinates
cp /group/mlr-lab/Saskia/ECoG_LASSO/scripts/mni_coordinates.csv /group/mlr-lab/Saskia/ECoG_RSL/derivatives/data/mni_coordinates.csv
