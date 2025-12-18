#!/bin/bash
echo "
++++++++++++++++++++++++" 

dirp=/group/mlr-lab/Saskia/ECoG_RSL
work=/group/mlr-lab/Saskia/ECoG_RSL/work

# runs hands-off section of preprocessing 
matlab_r2023b -nodisplay -nodesktop -r "addpath('$dirp/src/');calculate_fold_by_fold_correlations;exit"
