% calculates fold-by-fold correlations. These can be transformed into group
% results with calculate_timecourses.m and subsequently plotted with
% plot_results.m .

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
addpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/WISC_MVPA/src/');
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root);

% get target dimensions for RSL and rescale (see Cox et al., 2024, Imaging
% Neuroscience, supplementary materials)
load('/group/mlr-lab/Saskia/ECoG_RSL/src/dilkina_norms.mat');
[U,z] = embed_similarity_matrix(dilkinaNorms,3);
C = rescale_embedding(U,z);

% load results
load('/group/mlr-lab/Saskia/ECoG_RSL/derivatives/analysis/correlation/grOWL/performance/final/final_performance.mat');

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

% load results into a struct.

% for each data type
for t = 1:length(dataType)

    % if this is a voltage job (and so we don't have frequency ranges)
    if strcmp(dataType{t},'voltage')

        % for each wavelet centre
        for w = 1:length(waveletCentre)
           
            % load metadata
            load([root,'/windowed/',dataType{t},'/waveletCentre/',sprintf('%04d',waveletCentre(w)),'/metadata.mat'])
            % display verbose output to show us where it is up to
            disp(['Data: ',dataType{t},', wavelet centre: ',sprintf('%04d',waveletCentre(w))]);
            
            % for each patient
            for q = 1:length(patients)
                % for each holdout fold
                for ho = 1:10

                    % get results for that set of parameters
                    tmp = allResults((strcmp(allResults.dataType,dataType(t)) & allResults.waveletCentre == waveletCentre(w) & allResults.subject == patients(q) & allResults.cvholdout == ho), :);
                    % get predicted coordinates
                    tmp = tmp.Cz{1};

                    % get predicted coordinates for that holdout fold for
                    % dimension 1
                    predictedCoords = tmp(metadata(q).cvind(:,1) == ho, 1);
                    % get target coordinates for those stimuli for D1
                    targetCoords = C(metadata(q).cvind(:,1) == ho, 1);
                    % calculate correlation for all items
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D1.all.final(ho,q) = corr(targetCoords,predictedCoords);
                    % calculate correlation just for animate and just for
                    % inanimate items
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D1.animate.final(ho,q) = corr(targetCoords(1:5),predictedCoords(1:5));
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D1.inanimate.final(ho,q) = corr(targetCoords(6:10),predictedCoords(6:10));
                    % repeat for dimension 2
                    predictedCoords = tmp(metadata(q).cvind(:,1) == ho, 2);
                    targetCoords = C(metadata(q).cvind(:,1) == ho, 2);
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D2.all.final(ho,q) = corr(targetCoords,predictedCoords);
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D2.animate.final(ho,q) = corr(targetCoords(1:5),predictedCoords(1:5));
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D2.inanimate.final(ho,q) = corr(targetCoords(6:10),predictedCoords(6:10));
                    % repeat for dimension 3
                    predictedCoords = tmp(metadata(q).cvind(:,1) == ho, 3);
                    targetCoords = C(metadata(q).cvind(:,1) == ho, 3);
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D3.all.final(ho,q) = corr(targetCoords,predictedCoords);
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D3.animate.final(ho,q) = corr(targetCoords(1:5),predictedCoords(1:5));
                    results.(dataType{t}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D3.inanimate.final(ho,q) = corr(targetCoords(6:10),predictedCoords(6:10));
                    
                end
            end
            clear metadata
        end

    % otherwise, for phase and power jobs (for which we do have frequency
    % ranges)
    else

        % for each frequency range
        for f = 1:length(frequencyRange)
            % for each wavelet centre
            for w = 1:length(waveletCentre)
               
                % load metadata
                load([root,'/windowed/',dataType{t},'/range/',frequencyRange{f},'/waveletCentre/',sprintf('%04d',waveletCentre(w)),'/metadata.mat'])
                % display verbose output to show us where it is up to
                disp(['Data: ',dataType{t},', frequency range: ',frequencyRange{f},', wavelet centre: ',sprintf('%04d',waveletCentre(w))]);
                
                % for each patient
                for q = 1:length(patients)
                    % for each holdout fold
                    for ho = 1:10
    
                        % get results for that set of parameters
                        tmp = allResults((strcmp(allResults.dataType,dataType(t)) & strcmp(allResults.frequencyRange,frequencyRange(f)) & allResults.waveletCentre == waveletCentre(w) & allResults.subject == patients(q) & allResults.cvholdout == ho), :);
                        % get predicted coordinates
                        tmp = tmp.Cz{1};
    
                        % get predicted coordinates for that holdout fold for
                        % dimension 1
                        predictedCoords = tmp(metadata(q).cvind(:,1) == ho, 1);
                        % get target coordinates for those stimuli for D1
                        targetCoords = C(metadata(q).cvind(:,1) == ho, 1);
                        % calculate correlation for all stimuli
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D1.all.final(ho,q) = corr(targetCoords,predictedCoords);
                        % calculate correlation just for animate and just for
                        % inanimate stimuli
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D1.animate.final(ho,q) = corr(targetCoords(1:5),predictedCoords(1:5));
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D1.inanimate.final(ho,q) = corr(targetCoords(6:10),predictedCoords(6:10));
                        % repeat for dimension 2
                        predictedCoords = tmp(metadata(q).cvind(:,1) == ho, 2);
                        targetCoords = C(metadata(q).cvind(:,1) == ho, 2);
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D2.all.final(ho,q) = corr(targetCoords,predictedCoords);
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D2.animate.final(ho,q) = corr(targetCoords(1:5),predictedCoords(1:5));
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D2.inanimate.final(ho,q) = corr(targetCoords(6:10),predictedCoords(6:10));
                        % repeat for dimension 3
                        predictedCoords = tmp(metadata(q).cvind(:,1) == ho, 3);
                        targetCoords = C(metadata(q).cvind(:,1) == ho, 3);
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D3.all.final(ho,q) = corr(targetCoords,predictedCoords);
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D3.animate.final(ho,q) = corr(targetCoords(1:5),predictedCoords(1:5));
                        results.(dataType{t}).(frequencyRange{f}).(['waveletCentre',sprintf('%04d',waveletCentre(w))]).D3.inanimate.final(ho,q) = corr(targetCoords(6:10),predictedCoords(6:10));
                        
                    end
                end
                clear metadata
            end
        end
    end
end

% replace nans
results = replace_nan(results);

% save struct
disp('Saving results..')
if ~exist([root,'/results/'])
    mkdir([root,'/results/']);
end
save([root,'/results/fold_by_fold_correlations.mat'],'results','-v7.3');
disp('Saved!')



