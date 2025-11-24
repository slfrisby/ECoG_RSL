% Write tuning .yaml for RSL.

% setup
addpath(genpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/'))
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src');
root = '/group/mlr-lab/Saskia/ECoG_RSL/';
cd(root);

% set data path on CHTC. This should be the path where the folders phase, power
% and voltage (and permutation_struct.mat) are located. 
chtcPath = '/home/sfrisby/ECoG_RSL/data/';

% construct .yaml

% specify regularization (Brits, beware American spelling)
y.regularization = 'growl2';
% permutation test - set false for tuning
y.PermutationTest = false;
% save results as .mat file
y.SaveResultsAs = 'mat';
% use hyperband
y.SearchWithHyperband = true;

% should we fit the intercept of the model? No (0, default) or yes (1)
y.bias = 0;
% hyperparameters - range to search (default 0:6) and distribution
y.lambda.args = {0,6};
y.lambda.distribution = 'uniform';
y.lambda1.args = {0,6};
y.lambda1.distribution = 'uniform';
% hyperband - aggressiveness (default 3), budget (default 200), hyperparameters
y.HYPERBAND.aggressiveness = 3;
y.HYPERBAND.budget = 200; 
y.HYPERBAND.hyperparameters = {'lambda','lambda1'};
% specify lambda sequence - linear (default) or exponential
y.LambdaSeq = 'linear';
% normalize using z-scoring
y.normalize_data = 'zscore';
% normalize the target to the center, i.e. subtract the mean value from
% each target value
y.normalize_target = 'center';
% normalize the data to the training set during training
y.normalize_wrt = 'training_set';

% prepare data. Get all .mat files in target directories
matFiles = dir([root,'/derivatives/windowed/**/*.mat']);
% concatenate filename and folder name to get full file path
fullFilePaths = arrayfun(@(x) fullfile(x.folder, x.name), matFiles, 'UniformOutput', false);
% edit filepath to the filepath on CHTC
fullFilePaths = cellfun(@(x) strrep(x, [root,'derivatives/windowed/'], chtcPath), fullFilePaths, 'UniformOutput', false);
% index data files
dataIndex = contains(fullFilePaths,'sub-');
dataPaths = fullFilePaths(dataIndex);
% add files to .yaml
y.data = dataPaths;
% specify name of data variable in these files
y.data_var = 'X';

% prepare metadata. Index metadata files
metadataIndex = contains(fullFilePaths,'metadata.mat');
metadataPaths = fullFilePaths(metadataIndex);
% each data file needs to be matched to the correct metadata file. This
% means repeating the number of  times each metadata file is mentioned in
% the list. 
% get number of participants. This is the number of data files there are
% within each data subdirectory
nSubjects = numel(unique({matFiles.name})) - 2; % because 2 of the files returned by this operation are metadata.mat and permutation_struct.mat
metadataPaths = repelem(metadataPaths,nSubjects,1);
% add files to .yaml
y.metadata = metadataPaths;
% specify name of metadata variable in these files
y.metadata_var = 'metadata';

% use the first cross-validation index of those available
y.cvscheme = 1;
% set cross-validation fold structure for inner loop. Initialise cell array
innerLoopFolds = cell(10,9);
% for each row
for i = 1:10
    % get the numbers 1:10, but with the number i missing
    row = setdiff(1:10,i);
    % fill in the cell array
    innerLoopFolds(i,:) = num2cell(row);
end
% add fold structure to .yaml
y.cvholdout = innerLoopFolds;
% set cross-validation fold structure for outer loop
y.finalholdout = num2cell(1:10);

% provide information needed to identify the correct row of
% metadata.targets
y.target_label = 'semantic';
y.target_type = 'similarity';
y.sim_source = 'DilkinaNormalised'; % careful - British spelling used for metadata (despite American spelling used for toolbox compatibility!)
y.sim_metric = 'cosine';
% specify number of singular vectors into which to decompose the target
% representational similarity matrix. N.B. if 0 < tau < 1, the similarity
% matrix will instead be decomposed into the number of components needed to
% explain that fraction of the variance.
y.tau = 3;

% specify the orientation of the coordinates (should match
% metadata.coords.orientation)
y.orientation = 'mni';

% specify filters (within metadata.filters)
y.filters = {'rowFilter';'columnFilter'};

% specify whether to write coefficients on each feature (0) or not (1,
% default). This is only needed when coefficients will be plotted or
% interpreted
y.SmallFootprint = 1;
% specify naming conventions for data files (in a manner compatible with
% sprintf)
y.subject_id_fmt = 'sub-%02d.mat';
% set path to MATLAB binary on CHTC. !! When using apptainer, we set this
% to the name of the shell script instead, to placate setupJobs
y.executable = '/home/sfrisby/GitHub/WISC_MVPA/run_WISC_MVPA_Apptainer.sh';
% set path to wrapper shell script for MATLAB binary
y.wrapper = '/home/sfrisby/GitHub/WISC_MVPA/run_WISC_MVPA_Apptainer.sh';

% set variables that are distributed across jobs (i.e. every job receives
% one copy of data, one corresponding copy of metadata, and one combination of inner- and outer-loop holdout
% folds)
y.EXPAND = {{'data';'metadata'};{'finalholdout','cvholdout'}};
% state which files every job should receive
y.COPY = {'executable';'wrapper'};
% set up input queue (which will be automatically created and recorded in
% queue_input.csv). Each job must receive data plus the correct metadata
y.URLS = {'data','metadata'};

% write .yaml

% block style is important for setupJobs
yaml.dumpFile([root,'/derivatives/analysis/correlation/grOWL/performance/tune/performance_tune.yaml'],y,'block');

% also make dummy .yaml, for testing. This has only 1 data and
% metadata entry
y.data = y.data(1);
y.metadata = y.metadata(1);
yaml.dumpFile([root,'/derivatives/analysis/correlation/grOWL/performance/tune/TEST_performance_tune.yaml'],y,'block');

