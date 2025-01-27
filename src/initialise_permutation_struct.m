% make a permutation struct. This contains 10,000 random orders of stimulus
% labels. These are randomised once for each participant, but then fixed to
% enable comparison across frequency ranges, timepoints, and regularisation
% penalties.

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src');
root = '/group/mlr-lab/Saskia/ECoG_RSL/';
cd(root);

% load list of stimuli
load('/group/mlr-lab/Saskia/ECoG_RSL/src/stimuli.mat');

% get files with data in
dataDirs = dir([root,'/derivatives/data/sub*']);

% initialise output
permutationStruct = {};

% loop over participants
for s = 1:size(dataDirs)

    % fill in

    % subject ID
    permutationStruct(s).subject = str2num(erase(dataDirs(s).name,'sub-'));

    % stimuli
    permutationStruct(s).stimuli = stimuli;

    % permutation indices
    for i = 1:10000
        indices(:,i) = randperm(size(stimuli,1))';
    end
    permutationStruct(s).permutation_index = permutationStruct;

end

% save
save([root,'/derivatives/windowed/permutation_struct.mat'],'permutationStruct','-v7.3');