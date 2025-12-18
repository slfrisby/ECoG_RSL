#!/bin/bash

dirp=/group/mlr-lab/Saskia/ECoG_RSL/
if [ ! -d $dirp/work/logs/ ]; then
mkdir -p $dirp/work/logs/
fi

# calculate fold-by-fold correlations
sbatch -o $dirp/work/logs/correlations.out -c 16 -q --job-name=ECoG $dirp/src/sub_matlabjob.sh

