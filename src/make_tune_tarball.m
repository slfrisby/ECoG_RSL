% make a file structure (complete with data, metadata, .yamls and .sub
% files) for running the tune stage of the analysis on CHTC (wrapper
% script).

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src');
root = '/group/mlr-lab/Saskia/ECoG_RSL/';
cd(root);

% if no metadata template is present, create one
if ~exist([root,'/derivatives/metadata_template.mat'])
    initialise_metadata;
end
% if no permutation struct is present, create one
if ~exist([root,'/derivatives/windowed/permutation_struct.mat'])
    initialise_permutation_struct;
end

% load coordinates of all electrodes from .csv 
coordinates = readtable([root,'/derivatives/data/mni_coordinates.csv']);

% get files with data in
dataDirs = dir([root,'/derivatives/data/sub*']);
dataDirs = dataDirs([dataDirs.isdir]);

% loop over participants
for s = 1:size(dataDirs)

    % load decibel-normalised power data
    load([root,'/derivatives/data/',dataDirs(s).name,'/dBpower.mat'])
    % window
    window_freq_data(dBpower,coordinates,'power',dataDirs(s).name);

    % load phase data
    load([root,'/derivatives/data/',dataDirs(s).name,'/phase.mat'])
    % window
    window_freq_data(phase,coordinates,'phase',dataDirs(s).name);

    % load voltage data
    load([root,'/derivatives/data/',dataDirs(s).name,'/voltage.mat'])
    % window
    window_volt_data(voltage,dataDirs(s).name,coordinates);
    
end

% tune, final, and perm directories will be in a directory called /analysis
if ~exist([root,'derivatives/analysis/correlation/grOWL/performance/'])

    % make directories
    mkdir([root,'derivatives/analysis/correlation/grOWL/performance/']);
    mkdir([root,'derivatives/analysis/correlation/grOWL/performance/tune']);
    % populate directory with:
    % tune.yaml
    write_tune_yaml;
    % tune.sub
    copyfile([root,'/dependencies/WISC_MVPA/templates/apptainer_sub.sub'],[root,'derivatives/analysis/correlation/grOWL/performance/tune/tune.sub']);

end

% tarball for transfer to CHTC
tar([root,'/derivatives/tune.tar'],{[root,'/derivatives/windowed/power'],[root,'/derivatives/windowed/phase'],[root,'/derivatives/windowed/voltage'],[root,'/derivatives/windowed/permutation_struct.mat'],[root,'derivatives/analysis']})
gzip([root,'/derivatives/tune.tar'])
