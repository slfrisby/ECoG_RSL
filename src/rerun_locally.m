% After having downloaded a file tree from CHTC, this script checks inside
% each folder for results.mat. It then reruns the jobs.

% THIS SCRIPT SHOULD BE USED WHEN THE NUMBER OF BAD JOBS IS SMALL (< 1000).
% To rerun large numbers of missing jobs, it is more efficient to rerun on
% CHTC. To set this up, use rerun_on_CHTC.m .

% setup
addpath(genpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/WISC_MVPA/'));
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/analysis/correlation/grOWL/performance/final/';

% read queue_input.csv
opts = detectImportOptions([root,'/queue_input.csv'], 'Delimiter', ',');
opts.VariableTypes(:) = {'char'};
queueInput = table2cell(readtable([root,'/queue_input.csv'],opts));

% initialise list
badResults = {};

% for every folder in queue_input.csv
for i = 1:size(queueInput,1)
    % print the folder name
    disp(queueInput{i,1})
    % attempt to load the file
    try load([root,'/',queueInput{i,1},'/results.mat'])
        % if it fails
    catch
        % add the directory containing the bad results.mat to the list
        badResults = [badResults;queueInput{i,1}];
        % enter the directory
        cd([root,'/',queueInput{i,1}])
        % remove the bad results.mat
        delete([root,'/',queueInput{i,1},'/results.mat'])
        % add the data that that job needs to path
        [dataDir,~,~] = fileparts([erase(root,'/analysis/correlation/grOWL/performance/final/'),'/windowed/',erase(queueInput{i,2},'/home/sfrisby/ECoG_RSL/data/')]);
        addpath(dataDir);
        % run WISC_MVPA
        WISC_MVPA;
        % remove the data that that job needs, so another job can be run
        rmpath(dataDir);
    end
end

% save the list of bad files, just in case
save('/group/mlr-lab/Saskia/ECoG_RSL/derivatives/badFinalResults.mat','badResults')

