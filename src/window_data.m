% Divide data into overlapping windows. 

% setup
clear loadedprofile vers
cd('/group/mlr-lab/Saskia/ECoG_RSL/')

% get files with data in
datadirs = dir([pwd,'/data/sub*']);

% loop over participants
for s = 1:size(datadirs)

    load([pwd,'/data/',datadirs(s).name,'/ieeg/',datadirs(s).name,'_task-naming_run-01_ieeg.mat'])
    
end



a = 1;


