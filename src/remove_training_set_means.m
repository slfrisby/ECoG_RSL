% When plotting predicted coordinates, we need to adjust the predictions to
% account for the mean of the training set. The reasons for this are
% explained fully in Supplement C of Cox et al. (2024), Imaging
% Neuroscience.

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/WISC_MVPA/src/');
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root);

% get target dimensions for RSL and rescale (see Cox et al., 2024, Imaging
% Neuroscience, supplementary materials)
load('/group/mlr-lab/Saskia/ECoG_RSL/src/dilkina_norms.mat');
[U,z] = embed_similarity_matrix(dilkinaNorms,3);
C = rescale_embedding(U,z);

% load cross-validation indices
load('/group/mlr-lab/Saskia/ECoG_RSL/src/cross-validation_index.mat');
% we used the first column of this for cross-validation
cvind = cvind(:,1);

% load results
load([root,'/analysis/correlation/grOWL/performance/final/final_performance.mat']);

% set patient IDs - excluding patient 17 
patients = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 20, 21, 22];
% set data types - phase, power, or voltage
dataType = {'power','phase','voltage'};
% set frequency ranges
frequencyRange = {'all','theta','alpha','beta','gamma','highGamma'};
% set timepoints on which the wavelet used to extract time-frequency power
% or phase is centred (or, for voltage jobs, the window on which the window
% is centred)
waveletCentre = 0:10:1650;

% initialise a (minimalist) output table. Each combination of patient, data type, frequency
% range, and wavelet centre appears once. 
adjustedResults = unique(allResults(:,["subject","dataType","frequencyRange","waveletCentre"]));
% add an additional column in which to store adjusted coordinates
adjustedResults.adjustedCoordinates = cell(size(adjustedResults,1),1);

% for each row of this output table (i.e. each combination of the variables
% above)
for i = 1:size(adjustedResults,1)

    % initialise output
    adjustedCoordinates = zeros(100,3);

    % for each holdout fold
    for ho = 1:10

        % if it is a voltage job (and so we don't have frequency ranges)
        if strcmp(adjustedResults{i,2}{1},'voltage')
            % get results for that set of parameters
            tmp = allResults((allResults.subject == adjustedResults{i,1} & strcmp(allResults.dataType,adjustedResults{i,2}{1}) & allResults.waveletCentre == adjustedResults{i,4} & allResults.cvholdout == ho), :);
            % display verbose output to show us where it is up to
            disp(['Patient: ',num2str(adjustedResults{i,1}),', data: ',adjustedResults{i,2}{1},', wavelet centre: ',num2str(adjustedResults{i,4})]);          
        % otherwise, for phase and power jobs (for which we do have frequency
        % ranges)
        else
            % get results for that set of parameters
            tmp = allResults((allResults.subject == adjustedResults{i,1} & strcmp(allResults.dataType,adjustedResults{i,2}{1}) & strcmp(allResults.frequencyRange,adjustedResults{i,3}{1}) & allResults.waveletCentre == adjustedResults{i,4} & allResults.cvholdout == ho), :);
            % display verbose output to show us where it is up to
            disp(['Patient: ',num2str(adjustedResults{i,1}),', data: ',adjustedResults{i,2}{1},', frequency range: ',adjustedResults{i,3}{1},', wavelet centre: ',num2str(adjustedResults{i,4})]);       
        end

        % get the coordinates for just the held-out (test set) items
        testCoordinates = tmp.Cz{1}(cvind == ho,:);

        % we now need to add the mean of the TRAINING set targets back into these.
        % So get the training set target coordinates
        trainCoordinates = C(cvind ~= ho,:);
        % calculate the mean of the training set, add it to the test
        % coordinates, and fill in the ouptut
        adjustedCoordinates(cvind == ho,:) = testCoordinates + mean(trainCoordinates);    
    end

    % add the adjusted coordinates to the adjusted results
    adjustedResults(i,'adjustedCoordinates') = {adjustedCoordinates};

end

% save
save([root,'/results/adjusted_coordinates.mat'],'adjustedResults','-v7.3');

