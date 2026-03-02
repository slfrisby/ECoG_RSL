# ECoG RSL

Run Representational Similarity Learning workflow on Kyoto ECoG data.

## Order of operations: 

N.B. The below instructions assume that you have access to both the MRC CBU (Cambridge) and the CHTC (UW-Madison) clusters and are familiar with running jobs on both. It also assumes that, on CHTC, you have the WISC MVPA workflow set up (https://github.com/crcox/WISC_MVPA), including a virtual environment containing InputSetup code (https://github.com/crcox/InputSetup) and an Apptainer container in which the analysis can be run on the execute nodes (https://github.com/slfrisby/WISC_MVPA_Apptainer).

1. `get_data.sh` - this should be run on the CBU cluster and pulls preprocessed ECoG data (ventral temporal lobe only) from a previous project.
2. `make_tune_tarball.m` - this wrapper script should be run on the CBU cluster and makes a tarball. The tarball can be transferred to CHTC and contains everythingt that is needed to set up the analysis. Specifically, this script:
	- makes a template that can be used to create metadata (using `initialise_metadata.m`, which uses `stimuli.mat`, `dilkina_norms.mat`, and `cross-validation_index.mat`)
	- makes a permutation struct (`initialise_permutation_struct.mat`, which uses `stimuli.mat`)
	- temporally windows the data (using `window_freq_data.m`, `get_freq_win`, and `window_volt_data.m`; these scripts make accompanying metadata using `update_metadata.m`)
	- makes a `tune` directory and populates it with `tune.yaml` and `tune.sub` files
	- tarballs everything
3. Transfer the data to CHTC and run the /tune stage of the analysis. Then pull the results back to your computer and see whether the jobs have been successful - sometimes jobs fail randomly. Two scripts can help with this by rerunning failed jobs:
	- `rerun_on_chtc.m` will check for every expected output file and will adjust the input queue file to contain only jobs that need to be rerun. If this number is large (over 1000), it is quicker to transfer the adjusted input queue file back to CHTC and rerun the jobs there. Alternatively, if the number of jobs to rerun is small (less than 1000)...
	- `rerun_locally.m` can be run once the almost-complete results have been transferred to the CBU cluster.	
4. Transfer the results to the CBU cluster (if not done already). 
5. `load_model_performance.m` - this script collates the output of the /tune stage into a single .mat file (using `load_from_condor.m`).
6. `identify_best_config.m` - this script uses the output of `load_model_performance.m` to set hyperparameters for the /final (and optional /perm) stages of the analysis and to make .yamls and .sub files for running that stage (using `make_random_seed.m`).
7. Transfer those .yamls and .sub files to CHTC and run the /final stage of the analysis. Use `rerun_on_chtc.m` and `rerun_locally.m` to ensure that all jobs are complete. 
8. Generate results!
	- To calculate cross-validated correlations over time, use `calculate_fold_by_fold_correlations.m` to calculate all correlations (which uses `replace_nan.m`), `calculate_timecourses.m` to transform these into group-average timecourses that can be plotted (which can be run on the compute node with `sub_job.sh` and `sub_matlabjob.sh`), and `plot_results.m` to plot them. `plot_frequency_vs_volage.m` plots frequency results (power or phase) against voltage. `plot_frequency_ranges.m` plots results for all frequency ranges on the same plot. `plot_range_vs_frequency.m` plots results for one frequency against all frequencies. 
	- To visualise predicted coordinates, use `remove_training_set_means.m` to adjust predictions to be comparable across holdout folds (see the supplmenentary material of [Cox et al. (2024)](https://direct.mit.edu/imag/article/doi/10.1162/imag_a_00093/119416/Representational-similarity-learning-reveals-a) for a full explanation of why this is necessary). Then use `plot_predicted_coordinates.m` to plot images and `plot_trajectory_videos.sh` to make these images into videos. 
