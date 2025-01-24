% Divide all power, phase and voltage data into windows
% (wrapper script). 

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src');
root = '/group/mlr-lab/Saskia/ECoG_RSL/';
cd(root);

% get files with data in
datadirs = dir([root,'/derivatives/data/sub*']);

% loop over participants
for s = 1:size(datadirs)

    % load decibel-normalised power data
    load([root,'/derivatives/data/',datadirs(s).name,'/dBpower.mat'])
    % window
    window_freq_data(dBpower,'power',datadirs(s).name);

    % load phase data
    load([root,'/derivatives/data/',datadirs(s).name,'/phase.mat'])
    % window
    window_freq_data(phase,'phase',datadirs(s).name);

    % load voltage data
    load([root,'/derivatives/data/',datadirs(s).name,'/voltage.mat'])
    % window
    window_volt_data(voltage,datadirs(s).name);
    
end

% tarball for transfer to CHTC
tar([root,'/derivatives/data.tar'],{[root,'/derivatives/windowed/power'],[root,'/derivatives/windowed/phase'],[root,'/derivatives/windowed/voltage']})
gzip([root,'/derivatives/data.tar'])



