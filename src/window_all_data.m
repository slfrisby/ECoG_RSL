% Divide all power, phase and voltage data into windows
% (wrapper script). 

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

% tarball for transfer to CHTC
tar([root,'/derivatives/data.tar'],{[root,'/derivatives/windowed/power'],[root,'/derivatives/windowed/phase'],[root,'/derivatives/windowed/voltage'],[root,'/derivatives/windowed/permutation_struct.mat']})
gzip([root,'/derivatives/data.tar'])



