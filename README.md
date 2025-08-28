# ECoG RSL

Run Representational Similarity Learning workflow on Kyoto ECoG data.

## Order of operations: 

1. Create an Apptainer container within which the analysis can be run, following the instructions here: https://github.com/slfrisby/WISC_MVPA_Apptainer
2. `get_data.sh` - this should be run on the CBU cluster and pulls preprocessed ECoG data (ventral temporal lobe only) from a previous project.
3. `make_tune_tarball.m` - this wrapper script should be run on the CBU cluster and makes synthetic data, matching metadata, .yamls needed for the first (tune) stage of the analysis, and the correct directory tree. 

