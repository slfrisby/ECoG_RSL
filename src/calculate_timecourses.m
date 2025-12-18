% takes fold-by-fold correlations (calculated with
% calculate_fold_by_fold_correlations.m) and creates group timecourses
% (participants x timepoints; each cell is mean over holdout folds for that
% participant).

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root);

% load fold-by-fold correlations
load([root,'/results/fold_by_fold_correlations.mat']);

% % set patient IDs - excluding patient 17 
patients = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 20, 21, 22];
% set data types - power, phase, or voltage
dataType = {'power','phase','voltage'};
% set frequency ranges
frequencyRange = {'all','theta','alpha','beta','gamma','highGamma'};
% set timepoints on which the wavelet used to extract time-frequency power
% or phase is centred (or, for voltage jobs, the window on which the window
% is centred)
waveletCentre = 0:10:1650;
% set dimensions
dimension = {'D1','D2','D3'};
% set subsets of items
item = {'all','animate','inanimate'};

% for each data type 
for t = 1:length(dataType)

    % if this is a voltage job (and so we don't have frequency ranges)
    if strcmp(dataType{t},'voltage')

        % for each dimension
        for d = 1:length(dimension)
            % for each set of items
            for i = 1:length(item)

                % display verbose output to show us where it is up to
                disp(['Data: ',dataType{t},', dimension: ',dimension{d},', items: ',item{i}]);

                % for each wavelet centre
                for w = 1:length(waveletCentre)

                    % for each patient
                    for q = 1:length(patients)
                        % get the accuracy for each fold and store
                        individualTimecourses.(dataType{t}).(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))])(:,w) = results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).(dimension{d}).(item{i}).final(:,q);
                    end

                    % calculate mean over folds for each participant and
                    % store the group result
                    groupTimecourses.(dataType{t}).(dimension{d}).(item{i})(:,w) = mean(results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).(dimension{d}).(item{i}).final)';

                end

            end
        end

    % otherwise, for phase and power jobs (for which we do have frequency
    % ranges)
    else

        % for each frequency range
        for f = 1:length(frequencyRange)
            % for each dimension
            for d = 1:length(dimension)
                % for each set of items
                for i = 1:length(item)
    
                    % display verbose output to show us where it is up to
                    disp(['Data: ',dataType{t},', frequency range: ',frequencyRange{f},', dimension: ',dimension{d},', items: ',item{i}]);
    
                    % for each wavelet centre
                    for w = 1:length(waveletCentre)

                         % for each patient
                        for q = 1:length(patients)
                            % get the accuracy for each fold and store
                            individualTimecourses.(dataType{t}).(frequencyRange{f}).(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))])(:,w) = results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).(dimension{d}).(item{i}).final(:,q);
                        end
    
                        % calculate mean over folds for each participant
                        groupTimecourses.(dataType{t}).(frequencyRange{f}).(dimension{d}).(item{i})(:,w) = mean(results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).(dimension{d}).(item{i}).final)';
    
                    end
    
                end
            end
        end
       
    end

end

% save struct
disp('Saving results..')
save([root,'/results/timecourses.mat'],'individualTimecourses','groupTimecourses','-v7.3');
disp('Saved!')

