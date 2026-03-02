% takes a table of adjusted coordinates (made with
% remove_training_set_means.m) and calculates the average coordinates
% across participants. 

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root);

% if input data are missing
if ~exist([root,'/results/adjusted_coordinates.mat'])
    % generate them
    remove_training_set_means;
% otherwise, load them
else
    load([root,'/results/adjusted_coordinates.mat']);
end

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

% initialise a (minimalist) output table. Each combination of data type, frequency
% range, and wavelet centre appears once. 
averagedAdjustedResults = unique(adjustedResults(:,["dataType","frequencyRange","waveletCentre"]));
% add an additional column in which to store averaged coordinates
averagedAdjustedResults.averagedAdjustedCoordinates = cell(size(averagedAdjustedResults,1),1);

% for each row of this output table (i.e. each combination of the variables
% above)
for i = 1:size(averagedAdjustedResults,1)

    % if it is a voltage job (and so we don't have frequency ranges)
    if strcmp(adjustedResults{i,2}{1},'voltage')
        % get results for that set of parameters
        tmp = adjustedResults((strcmp(adjustedResults.dataType,averagedAdjustedResults{i,1}{1}) & adjustedResults.waveletCentre == averagedAdjustedResults{i,3}), :);
        % display verbose output to show us where it is up to
        disp(['Data: ',averagedAdjustedResults{i,1}{1},', wavelet centre: ',num2str(averagedAdjustedResults{i,3})]);          
    % otherwise, for phase and power jobs (for which we do have frequency
    % ranges)
    else
        % get results for that set of parameters
        tmp = adjustedResults((strcmp(adjustedResults.dataType,averagedAdjustedResults{i,1}{1}) & strcmp(adjustedResults.frequencyRange,averagedAdjustedResults{i,2}{1}) & adjustedResults.waveletCentre == averagedAdjustedResults{i,3}), :);
        % display verbose output to show us where it is up to
        disp(['Data: ',adjustedResults{i,2}{1},', frequency range: ',adjustedResults{i,3}{1},', wavelet centre: ',num2str(adjustedResults{i,4})]);       
    end

    % keep just the coordinates
    tmp = tmp.adjustedCoordinates;
    % calculate the mean
    averagedAdjustedCoordinates = mean(cat(3,tmp{:}),3);

    % add the adjusted coordinates to the adjusted results
    averagedAdjustedResults(i,'averagedAdjustedCoordinates') = {averagedAdjustedCoordinates};

end

% save
save([root,'/results/averaged_adjusted_coordinates.mat'],'averagedAdjustedResults','-v7.3');


