% After having downloaded a file tree from CHTC, this script checks inside
% each folder for results.mat. It then creates a version of queue_input.csv
% which contains only jobs that did not run successfully (and produce
% results.mat) so that these jobs can be rerun.

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
    % if the folder contains results.mat
    if ~exist([root,'\',queueInput{i,1},'\results.mat'])
        missingIndex(i) = true;
    end
end

% index just the missing rows
queueInput = queueInput(missingIndex,:);

% write the new queue_input.csv
writecell(queueInput, [root,'/queue_input.csv'], 'Delimiter', ',');