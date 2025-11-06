function load_tuning_performance(path)
   
    % loop through tune directory tree and collate results into a single
    % .mat file.

    % Arguments:
    % - path = directory ending /tune and containing numbered directories. 

    % setup 
    addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
    addpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/jsonlab/');

    % load the directory tree. You are advised to set the option skip_large_matrices to true
    % (note that the names of the matrices to skip depend on whether it is SOSLASSO or RSL; see alternative version of this script: https://github.com/slfrisby/7TConvergent/blob/main/load_tuning_performance.m). 
    % This means that model coefficients, predicted coordinates, indices of 
    % nonzero model coefficients and coordinates of features (which are neither 
    % needed nor useful at the tune stage) are not written as output.
    SKIP = {'Uz', 'Cz', 'nz_rows', 'coords'};

    % load results
    disp('Loading results...')
    allResults = load_from_condor(path,'skip_large_matrices',true,'SKIP',SKIP); 

    % These are ECoG results and so we want to group the jobs not only by
    % participant but also by data type (phase/power/voltage), frequency
    % range, and timepoint. So load queue_input.csv
    disp('Adding additional information...')
    opts = detectImportOptions([path,'/queue_input.csv'], 'Delimiter', ',');
    queueInput = table2cell(readtable([path,'/queue_input.csv'],opts));
    % get just the second column
    jobInfo = queueInput(:,2);
    % and, since each job contains 9 folds, repeat each element 9 times
    jobInfo = repelem(jobInfo,9,1);

    % get the type of data (phase, power, or voltage) used in each job
    dataType = regexprep(jobInfo, '.*data/([^/]+)/.*', '$1');
    % get the frequency range for phase and power jobs
    frequencyRange = regexprep(jobInfo, '.*range/([^/]+)/.*', '$1');
    % N.B. if it is a voltage job, the above line will leave the character
    % vector unedited. We need to manually set frequencyRange to be empty
    % for voltage jobs
    frequencyRange(contains(frequencyRange, 'voltage')) = {''};
    % get the wavelet centre (or window centre for voltage jobs
    waveletCentre = str2double(regexprep(jobInfo, '.*waveletCentre/([^/]+)/.*', '$1'));

    % add the variables to the table
    allResults.dataType = dataType;
    allResults.frequencyRange = frequencyRange;
    allResults.waveletCentre = waveletCentre;

    % save the output as a .mat file
    disp('Saving...')
    save([path,'/tune_performance.mat'],'allResults','-v7.3');
    disp('Done!')

end
