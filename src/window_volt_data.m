function X = window_volt_data(data,subID,coordinates,varargin)
    % Divide time-frequency power or phase data into windows. 

    % Arguments:
    % data = data (items x electrodes x time in ms)
    % subID = subject ID in the form sub-xx (character array)
    % coordinates = coordinates of all electrodes for all participants
    % (loaded from mni_cooordinates.csv or similar file; n x 4 array - numeric ID, x, y, z)
    % electrodes = logical index of electrodes from which to get data (default = all electrodes in d)
    % windowMax = centre of final window (first window is at stimulus
    % onset, default = 1650 ms)
    % windowStep = distance between centres of successive windows (default
    % = 10 ms, i.e. windows centred at 0 ms, 10 ms, 20 ms ...)
    % windowSize = window size (default = 50 ms)
    % baseline = baseline length (default = 1000 ms, i.e. stimulus onset is index 1001)

    root = '/group/mlr-lab/Saskia/ECoG_RSL/';

    % parse optional inputs
    p = inputParser;
    addParameter(p,'electrodes',true(size(data,2),1));
    addParameter(p,'windowMax',1650);
    addParameter(p,'windowStep',10);
    addParameter(p,'windowSize',50);
    addParameter(p,'baseline',1000);
    parse(p,varargin{:});
    electrodes = p.Results.electrodes;
    windowMax = p.Results.windowMax;
    windowStep = p.Results.windowStep;
    windowSize = p.Results.windowSize;
    baseline = p.Results.baseline;

    % loop over window centres - these are the same as the centres of the
    % wavelets for time-frequency analysis
    for timepoint = baseline+1:windowStep:baseline+windowMax+1

        % get data 
        X = squeeze(data(:,electrodes,(timepoint-(0.5*windowSize)+1):(timepoint+(0.5*windowSize))));
        
        % reformat into 2-dimensional matrix (all timepoints for electrode 1, all timepoints for electrode 2, ...)
        X = permute(X,[1 3 2]);
        X = reshape(X,size(X,1),[]);
        % force X to be a double - very important for WISC_MVPA workflow!
        X = double(X);

        % make output directory
        if ~exist([root,'derivatives/windowed/voltage/waveletCentre/',sprintf('%04d',timepoint-(baseline+1)),'/'])
            mkdir([root,'derivatives/windowed/voltage/waveletCentre/',sprintf('%04d',timepoint-(baseline+1)),'/']);
            % copy metadata template in
            copyfile([root,'/derivatives/metadata_template.mat'],[root,'derivatives/windowed/voltage/waveletCentre/',sprintf('%04d',timepoint-(baseline+1)),'/metadata.mat']);
        end
        % save
        save([root,'derivatives/windowed/voltage/waveletCentre/',sprintf('%04d',timepoint-(baseline+1)),'/',subID,'.mat'],'X','-v7.3');
        % update metadata
        update_metadata([root,'derivatives/windowed/voltage/waveletCentre/',sprintf('%04d',timepoint-(baseline+1)),'/metadata.mat'],X,coordinates,subID,'voltage',sprintf('%04d',timepoint-(baseline+1)));
        
    end
end