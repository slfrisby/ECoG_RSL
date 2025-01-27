function window_freq_data(data,coordinates,dataType,subID)
    % Divide time-frequency power or phase data into windows. 

    % Arguments:
    % data = data (items x electrodes x timepoints x frequencies)
    % coordinates = coordinates of all electrodes for all participants
    % (loaded from mni_cooordinates.csv or similar file; n x 4 array - numeric ID, x, y, z)
    % dataType = data type - power or phase (character array)
    % subID = subject ID in the form sub-xx (character array)

    root = '/group/mlr-lab/Saskia/ECoG_RSL/';

    % information about each frequency range - name, index (in 1:60) of
    % lowest frequency, index of highest frequency
    ranges = {'all','theta','alpha','beta','gamma','highGamma'};
    lowIndex = [1,1,12,19,32,42];
    highIndex = [60,11,18,31,41,60];

    % for every timepoint in the matrix of data
    for timepoint = 1:size(data,3)
        
        % for every frequency range
        for range = 1:length(ranges)

            % get data for range of interest
            frequencies = false(size(data,4),1);
            frequencies(lowIndex(range):highIndex(range)) = true; 
            X = get_freq_win(data,timepoint,'frequencies',frequencies);

            % make output directory
            if ~exist([root,'derivatives/windowed/',dataType,'/range/',ranges{range},'/waveletCentre/',sprintf('%04d',(timepoint-1)*10),'/'])
                mkdir([root,'derivatives/windowed/',dataType,'/range/',ranges{range},'/waveletCentre/',sprintf('%04d',(timepoint-1)*10),'/'])
                % copy metadata in
                copyfile([root,'/derivatives/metadata_template.mat'],[root,'derivatives/windowed/',dataType,'/range/',ranges{range},'/waveletCentre/',sprintf('%04d',(timepoint-1)*10),'/metadata.mat']);        
            end
            % save data
            save([root,'derivatives/windowed/',dataType,'/range/',ranges{range},'/waveletCentre/',sprintf('%04d',(timepoint-1)*10),'/',subID,'.mat'],'X','-v7.3')
            % update metadata
            update_metadata([root,'derivatives/windowed/',dataType,'/range/',ranges{range},'/waveletCentre/',sprintf('%04d',(timepoint-1)*10),'/metadata.mat'],X,coordinates,subID,ranges{range},sprintf('%04d',(timepoint-1)*10));
            
        end   
    end
end