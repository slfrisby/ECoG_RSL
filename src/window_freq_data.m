function window_freq_data(data,dataType,subID)
    % Divide time-frequency power or phase data into windows. 

    % Arguments:
    % data = data (items x electrodes x timepoints x frequencies)
    % dataType = data type - power or phase (character array)
    % subID = subject ID in the form sub-xx (character array)

    root = '/group/mlr-lab/Saskia/ECoG_RSL/';

    % for every timepoint in the matrix of data
    for timepoint = 1:size(data,3)
        
        % get data for all freqencies
        X = get_freq_win(data,timepoint);
        % make output directory
        mkdir([root,'derivatives/windowed/',dataType,'/range/all/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/'])
        % save data
        save([root,'derivatives/windowed/',dataType,'/range/all/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/',subID,'.mat'],'X','-v7.3')
        
        % get data for theta range only
        frequencies = false(size(data,4),1);
        frequencies(1:11) = true;
        X = get_freq_win(data,timepoint,'frequencies',frequencies);
        % make output directory and save
        mkdir([root,'derivatives/windowed/',dataType,'/range/theta/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/'])
        save([root,'derivatives/windowed/',dataType,'/range/theta/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/',subID,'.mat'],'X','-v7.3')
        
        % get data for alpha range only
        frequencies = false(size(data,4),1);
        frequencies(12:18) = true;
        X = get_freq_win(data,timepoint,'frequencies',frequencies);
        % make output directory and save
        mkdir([root,'derivatives/windowed/',dataType,'/range/alpha/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/'])
        save([root,'derivatives/windowed/',dataType,'/range/alpha/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/',subID,'.mat'],'X','-v7.3')
        
        % get data for beta range only 
        frequencies = false(size(data,4),1);
        frequencies(19:31) = true;
        X = get_freq_win(data,timepoint,'frequencies',frequencies);
        % make output directory and save
        mkdir([root,'derivatives/windowed/',dataType,'/range/beta/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/'])
        save([root,'derivatives/windowed/',dataType,'/range/beta/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/',subID,'.mat'],'X','-v7.3')
        
        % get data for gamma range only
        frequencies = false(size(data,4),1);
        frequencies(32:41) = true;
        X = get_freq_win(data,timepoint,'frequencies',frequencies);
        % make output directory and save
        mkdir([root,'derivatives/windowed/',dataType,'/range/gamma/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/'])
        save([root,'derivatives/windowed/',dataType,'/range/gamma/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/',subID,'.mat'],'X','-v7.3')
        
        % get data for high gamma range only
        frequencies = false(size(data,4),1);
        frequencies(42:60) = true;
        X = get_freq_win(data,timepoint,'frequencies',frequencies);
        % make output directory and save
        mkdir([root,'derivatives/windowed/',dataType,'/range/highGamma/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/'])
        save([root,'derivatives/windowed/',dataType,'/range/highGamma/waveletCentre/',sprintf('%03d',(timepoint-1)*10),'/',subID,'.mat'],'X','-v7.3')
        
    end

end