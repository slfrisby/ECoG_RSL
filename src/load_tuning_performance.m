function load_tuning_performance(path)
    % the path here should be the project directory - it should CONTAIN
    % (not BE) a directory called \tune.
    % add useful toolboxes to path (update these paths to point to where
    % these directories are stored on your computer)
    addpath('C:\Users\slfri\ownCloud\7T_WISC_MVPA\scripts\WISC_MVPA\src')
    addpath('C:\Users\slfri\ownCloud\7T_WISC_MVPA\scripts\WISC_MVPA\util')
    addpath('C:\Users\slfri\ownCloud\7T_WISC_MVPA\scripts\WISC_MVPA\dependencies\jsonlab')
    addpath('C:\Users\slfri\ownCloud\7T_WISC_MVPA\scripts') 

    % load the directory tree. You are advised to set the option skip_large_matrices to true
    % (the names of the matrices to skip depend on whether it is SOSLASSO or RSL). This means that model 
    % coefficients, predicted coordinates, indices of nonzero model coefficients and coordinates of features 
    % (which are neither needed nor useful at the tune stage) are not written as output.
    if ~isempty(strfind(path,'correlation'))
        SKIP = {'Uz', 'Cz', 'nz_rows', 'coords'};
    elseif ~isempty(strfind(path,'classification'))
        SKIP = {'Wz', 'Yz', 'nz_rows', 'coords'};
    end
    Tallcv = load_from_condor([path,'\tune\'],'skip_large_matrices',true,'SKIP',SKIP); 
    % outputs of SOSLASSO have some of the character variables constructed
    % in a weird way. Correct this
    if ~isempty(strfind(path,'classification'))
        for i = 1:size(Tallcv,1)
            tmp = table2array(Tallcv(i,5));
            Tallcv(i,5) = {tmp{1,1}'};
            tmp = table2array(Tallcv(i,6));
            Tallcv(i,6) = {tmp{1,1}'};
        end
    end
    % save the output as a .mat file
    save([path,'\tune_performance.mat'],'Tallcv');
    % save the output as a .csv file
    writetable(Tallcv,[path,'\tune_performance.csv']);
end
