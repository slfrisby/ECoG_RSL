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

% initialise output 
metadata = {};

% loop over participants
for s = 1:size(dataDirs)

    % fill in metadata. Note that WISC_MVPA expects very specific labels
    % for any fields that are subsequently mentioned in .yaml files.

    % subject ID
    metadata(s).subject = str2num(erase(dataDirs(s).name,'sub-'));
    
    % decoding target (Dilkina norms)
    % label for ease of identification
    metadata(s).targets.label = 'semantic';
    % type (in this case, RSM)
    metadata(s).targets.type = 'similarity';
    % where the data is from 
    metadata(s).targets.sim_source = 'DilkinaNormalised';
    % similarity metric used to create RSM
    metadata(s).targets.sim_metric = 'cosine';
    % RSM itself
    metadata(s).targets.target = dilkinaNorms;

    % stimuli
    metadata(s).stimuli = stimuli;

    % filters
    % row filter will include all rows
    metadata(s).filters(1).label = 'rowFilter';
    metadata(s).filters(1).dimension = 1;
    metadata(s).filters(1).filter = true(100,1);
    % column filter will include all columns - leave unfilled for now
    metadata(s).filters(2).label = 'columnFilter';
    metadata(s).filters(2).dimension = 2;
    metadata(s).filters(2).filter = [];
    % animate filter will include only animate stimuli
    metadata(s).filters(3).label = 'animate';
    metadata(s).filters(3).dimension = 1;
    metadata(s).filters(3).filter = [true(50,1);false(50,1)];
    % inanimate filter will include only inanimate stimuli
    metadata(s).filters(4).label = 'inanimate';
    metadata(s).filters(4).dimension = 1;
    metadata(s).filters(4).filter = [false(50,1);true(50,1)];
    % anterior filter will include electrodes in the anterior half of the
    % electrode coverage region. The most anterior electrode is at y = 28
    % and the most posterior one is at y = -74, so the midpoint is y = -23.
    % However, leave empty for now.
    metadata(s).filters(5).label = 'anterior';
    metadata(s).filters(5).dimension = 2;
    metadata(s).filters(5).filter = [];
    % posterior filter will include elecrodes in the posterior half - leave
    % empty for now
    metadata(s).filters(6).label = 'posterior';
    metadata(s).filters(6).dimension = 2;
    metadata(s).filters(6).filter = [];

    % coordinates
    % coordinates are given in MNI space
    metadata(s).coords.orientation = 'mni';
    % leave electrode labels, alternative coordinate labelling fields, and
    % coordinates themselves unfilled for now
    metadata(s).coords.labels = [];
    metadata(s).coords.ijk = [];
    metadata(s).coords.ind = [];
    metadata(s).coords.xyz = [];

    % cross-validation schemes
    metadata(s).cvind = cvind;

    % data dimensions - leave columns unfilled for now
    metadata(s).nrow = 100;
    metadata(s).ncol = [];

    % after this point, WISC_MVPA does not require field names to be
    % specified exactly. 
    
    % frequency range - leave unfilled for now
    metadata(s).range = '';
    % wavelet centre (or centre of corresponding sliding voltage window) -
    % leave unfilled for now
    metadata(s).waveletCentre = [];


end

% save metadata template
save([root,'/derivatives/metadata_template.mat'],'metadata')

