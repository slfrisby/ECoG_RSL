function identify_best_config(path)

    % use results of tuning stage to create .yamls for final and perm
    % stages. 

    % Arguments:
    % - path = directory ending /tune and containing numbered directories (character vector).  

    % setup
    addpath(genpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/'))
    addpath('/group/mlr-lab/Saskia/ECoG_RSL/src');
    root = '/group/mlr-lab/Saskia/ECoG_RSL/';
    cd(root);

    % set data path on CHTC. This should be the path where the folders phase, power
    % and voltage (and permutation_struct.mat) are located. 
    chtcPath = '/home/sfrisby/ECoG_RSL/data/';

    % check that tune_performance.mat exists. If it doesn't, create it
    if ~exist([path,'/tune_performance.mat'])
        load_tuning_performance(path);
    end

    % load results
    load([path,'/tune_performance.mat']);

    % also load tune.yaml
    if contains(path,'performance')
        y = yaml.loadFile([path,'/performance_tune.yaml']);
    elseif contains(path,'visualize')
        y = yaml.loadFile([path,'/visualize_tune.yaml']);
    end

    % we want to group the rows of table into groups with the same:
    % - data (participant ID, data type, frequency band, and timepoint)
    % - values of lambda and lambda1
    % - final holdout set
    % We also want to find, for each dataset, final holdout set, and
    % hyperparameter combination, the mean test-set loss (err1).

    % identify groups in order of first appearance
    [~,i,hyperparameterGroups] = unique(allResults(:,{'subject','finalholdout','lambda','lambda1','dataType','frequencyRange','waveletCentre'}),'rows','stable');
    % for each group, calculate the mean test-set loss
    err1 = splitapply(@mean,allResults.err1,hyperparameterGroups);
    % construct a summary
    summaryResults = allResults(i,{'subject','finalholdout','lambda','lambda1','dataType','frequencyRange','waveletCentre'});
    summaryResults.err1 = err1;

    % we then want to find out which combination of hyperparameters
    % performs best on each data matrix. So we group results by:
    % - data (participant ID, data type, frequency band, and timepoint)
    % - final holdout set

    % identify groups in order of first appearance
    [~,i,finalHoldoutGroups] = unique(summaryResults(:,{'subject','finalholdout','dataType','frequencyRange','waveletCentre'}),'rows','stable');
    % for each group, find the index of the row with the smallest err1
    bestHyperparameters = splitapply(@(rows,err1) rows(find(err1 == min(err1), 1)), (1:height(summaryResults))', summaryResults.err1, finalHoldoutGroups);
    % those hyperparameters are the ones that we are going to use for the
    % final (and perm) jobs.
    finalJobs = summaryResults(bestHyperparameters,:);
    
    % then adjust the content of the tune.yaml to make a final.yaml. 
    % this time, we are not using hyperband
    y.SearchWithHyperband = false;
    y = rmfield(y,{'HYPERBAND'});
    % each job will receive exactly one copy of data and the metadata,
    % hyperparameters, and holdout set that go with those data
    y.EXPAND = {{'data';'metadata';'cvholdout';'lambda';'lambda1'}};
    y.data = repmat(y.data,10,1);
    y.metadata = repmat(y.metadata,10,1);
    y.lambda = num2cell(finalJobs.lambda);
    y.lambda1 = num2cell(finalJobs.lambda1);
    % this syntax tells WISC MVPA to use all but one fold for testing and
    % one fold for evaluation
    y.finalholdout = int32(0);
    y.cvholdout = num2cell(finalJobs.finalholdout);

    % save the final.yaml. Block style is important for setupJobs
    if ~exist(replace(path,'tune','final'))
        mkdir(replace(path,'tune','final'));
    end
    yaml.dumpFile([replace(path,'tune','final'),'/performance_final.yaml'],y,'block');
    % also copy a .sub file across
    copyfile([root,'/dependencies/WISC_MVPA/templates/apptainer_sub.sub'],[replace(path,'tune','final'),'/final.sub']);


    % also make dummy .yaml for testing.
    dummy = y;
    dummy.data = dummy.data(1:50);
    dummy.metadata = dummy.metadata(1:50);
    dummy.lambda = dummy.lambda(1:50);
    dummy.lambda1 = dummy.lambda(1:50);
    dummy.cvholdout = dummy.cvholdout(1:50);
    yaml.dumpFile([replace(path,'tune','final'),'/DUMMY_performance_final.yaml'],y,'block');

    % then adjust the final .yaml to make a perm.yaml. 
    y.PermutationTest = true;
    % we tell it how to permute data (this keeps the permutations
    % consistent across things that we might want to compare)
    y.PermutationMethod = 'manual';
    y.PermutationIndex = [chtcPath,'/permutation_struct.mat'];
    y.perm_varname = 'permutationStruct';
    % each job will receive data, metadata, hyperparameters as above. It
    % will also receive one random seed.
    y.EXPAND = {{'data';'metadata';'cvholdout';'lambda';'lambda1'};'RandomSeed'};
    % the input queue will also include the permutation struct. 
    y.URLS = {'data';'metadata';'PermutationIndex'};
    % specify how many total permutations should be done and how many
    % permutations to do per job.
    y.RandomSeed = make_random_seed(1000,1000);
    
    % save the perm.yaml. Block style is important for setupJobs
    if ~exist(replace(path,'tune','perm'))
        mkdir(replace(path,'tune','perm'));
    end
    yaml.dumpFile([replace(path,'tune','perm'),'/performance_perm.yaml'],y,'block');
    % also copy a .sub file across
    copyfile([root,'/dependencies/WISC_MVPA/templates/apptainer_sub.sub'],[replace(path,'tune','perm'),'/perm.sub']);

    % also make dummy .yaml for testing.
    dummy = y;
    dummy.data = dummy.data(1:50);
    dummy.metadata = dummy.metadata(1:50);
    dummy.lambda = dummy.lambda(1:50);
    dummy.lambda1 = dummy.lambda(1:50);
    dummy.cvholdout = dummy.cvholdout(1:50);
    yaml.dumpFile([replace(path,'tune','perm'),'/DUMMY_performance_perm.yaml'],y,'block');

    % pause in debugger
    tmp = 'tmp';

end