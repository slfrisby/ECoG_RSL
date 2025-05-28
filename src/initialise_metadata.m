% Make a metadata file that can be adapted to match each window. 

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src');
root = '/group/mlr-lab/Saskia/ECoG_RSL/';
cd(root);

% load important things: list of stimuli, Dilkina feature-rating norms in
% the form of a representational similarity matrix (Dilkina & Lambon Ralph, 
% 2012, Frontiers in Human Neuroscience), cross-validation index describing
% assignment of stimuli to folds
load('/group/mlr-lab/Saskia/ECoG_RSL/src/stimuli.mat');
load('/group/mlr-lab/Saskia/ECoG_RSL/src/dilkina_norms.mat');
load('/group/mlr-lab/Saskia/ECoG_RSL/src/cross-validation_index.mat');

% load coordinates
coordinates = readtable([root,'/derivatives/data/mni_coordinates.csv']);

% get files with data in
dataDirs = dir([root,'/derivatives/data/sub*']);
dataDirs = dataDirs([dataDirs.isdir]);

% set up elements of the metadata that are common to all participants. Note
% that WISC_MVPA expects very specific labels for any fields that are 
% subsequently mentioned in .yaml files.

% decoding target (Dilkina norms)
% label for ease of identification
targets.label = 'semantic';
% type (in this case, RSM)
targets.type = 'similarity';
% where the data is from 
targets.sim_source = 'DilkinaNormalised';
% similarity metric used to create RSM
targets.sim_metric = 'cosine';
% RSM itself
targets.target = dilkinaNorms;

% filters
% row filter will include all rows
filters(1).label = 'rowFilter';
filters(1).dimension = 1;
filters(1).filter = true(100,1);
% column filter will include all columns - leave unfilled for now
filters(2).label = 'columnFilter';
filters(2).dimension = 2;
filters(2).filter = [];
% animate filter will include only animate stimuli
filters(3).label = 'animate';
filters(3).dimension = 1;
filters(3).filter = [true(50,1);false(50,1)];
% inanimate filter will include only inanimate stimuli
filters(4).label = 'inanimate';
filters(4).dimension = 1;
filters(4).filter = [false(50,1);true(50,1)];
% anterior filter will include electrodes in the anterior half of the
% electrode coverage region. The most anterior electrode is at y = 28
% and the most posterior one is at y = -74, so the midpoint is y = -23.
% However, leave empty for now.
filters(5).label = 'anterior';
filters(5).dimension = 2;
filters(5).filter = [];
% posterior filter will include elecrodes in the posterior half - leave
% empty for now
filters(6).label = 'posterior';
filters(6).dimension = 2;
filters(6).filter = [];

% coordinates
% coordinates are given in MNI space
coords.orientation = 'mni';
% leave electrode labels, alternative coordinate labelling fields, and
% coordinates themselves unfilled for now
coords.labels = [];
coords.ijk = [];
coords.ind = [];
coords.xyz = [];

% create metadata
metadata(1:size(dataDirs,1)) = struct('subject',[],'targets',targets,'stimuli',{stimuli},'filters',filters,'coords',coords,'cvind',cvind,'nrow',100,'ncol',[],'range',[],'waveletCentre',[]);

% loop over participants
for s = 1:size(dataDirs)

    % subject ID
    metadata(s).subject = str2num(erase(dataDirs(s).name,'sub-'));

end

% save metadata template
save([root,'/derivatives/metadata_template.mat'],'metadata','-v7.3');

