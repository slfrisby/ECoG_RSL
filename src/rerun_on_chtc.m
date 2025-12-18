% After having downloaded a file tree from CHTC, this script checks inside
% each folder for results.mat. It then creates a version of queue_input.csv
% which contains only jobs that did not run successfully (and produce
% results.mat) so that these jobs can be rerun.

% THIS SCRIPT SHOULD BE USED WHEN THE NUMBER OF BAD JOBS IS LARGE (< 1000).
% To rerun small numbers of missing jobs, it is more efficient to rerun
% locally. To do this, use rerun_locally.m .

% setup
root = 'C:\chtc\ECoG_RSL';
cd(root);

% read queue_input.csv
opts = detectImportOptions([root,'/queue_input.csv'], 'Delimiter', ',');
opts.VariableTypes(:) = {'char'};
queueInput = table2cell(readtable([root,'/queue_input.csv'],opts));

% create an index
missingIndex = false(size(queueInput,1),1);

% for every folder in queue_input.csv
for i = 1:size(queueInput,1)
    % print the folder name
    disp(queueInput{i,1})
    % attempt to load the file
    try load([root,'/',queueInput{i,1},'/results.mat'])
        % if it fails
    catch
        % print an indication
        disp('- requires rerun')
        % mark the file as missing
        missingIndex(i) = true;
    end
end

% index just the missing rows
queueInput = queueInput(missingIndex,:);

% write the new queue_input.csv
writecell(queueInput, [root,'/queue_input.csv'], 'Delimiter', ',');