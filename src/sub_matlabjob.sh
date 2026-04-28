#!/bin/bash
echo "
++++++++++++++++++++++++" 

dirp=/group/mlr-lab/Saskia/ECoG_RSL
work=/group/mlr-lab/Saskia/ECoG_RSL/work

# calculates fold-by-fold correlations
# matlab_r2023b -nodisplay -nodesktop -r "addpath('$dirp/src/');calculate_fold_by_fold_correlations;exit"

# plots trajectories (all items)
#matlab_r2023b -nodisplay -nodesktop -r "addpath('$dirp/src/');plot_predicted_coordinates;exit"

# plots trajectories ((averaged over categories))
matlab_r2023b -nodisplay -nodesktop -r "addpath('$dirp/src/');plot_averaged_predicted_coordinates;exit"
