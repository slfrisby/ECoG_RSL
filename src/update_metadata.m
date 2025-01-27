function update_metadata(metadataRoot,X,coordinates,subID,range,waveletCentre)
    % Fine-tune template metadata (produced with initialise_metadata.m) to
    % suit a particular timepoint. 

    % Arguments:
    % metadata = file path to metadata to update
    % X = window of data ready for decoding (items x features)
    % coordinates = coordinates of all electrodes for all participants
    % (loaded from mni_cooordinates.csv or similar file; n x 4 array - numeric ID, x, y, z)
    % subID = subject ID in the form sub-xx (character array)
    % range = frequency range (or voltage; character array)
    % waveletCentre = centre of wavelet or of corresponding voltage window
    % (! 4-DIGIT CHARACTER VECTOR)

    % % parse optional inputs
    % p = inputParser;
    % addParameter(p,'windowSize',50);
    % parse(p,varargin{:});
    % windowSize = p.Results.windowSize;

    % load metadata
    load(metadataRoot);

    % get row of metadata to update - the row with the correct subject ID
    s = find([metadata.subject]==str2double(erase(subID,'sub-')));

    % ensure that each column of X is associated with coordinates
    % get coordinates for that participant
    subjectCoordinates = coordinates{(coordinates{:,1}==metadata(s).subject),2:4};
    % voltage data are in the form: all timepoints for electrode 1, all timepoints for electrode 2, ...
    if strcmp(range,'voltage')
        % calculate the number of timepoints in each window
        windowSize = size(X,2)/size(subjectCoordinates,1);
        % replicate coordinates that number of times
        subjectCoordinates = repelem(subjectCoordinates,windowSize,1);
        metadata(s).coords.xyz = subjectCoordinates;
    % frequency data are in the form: all electrodes for frequency 1, all
    % electrodes for frequency 2, ...
    else
        nFrequencies = size(X,2)/size(subjectCoordinates,1);
        % replicate whole matrix of coordinates that number of times
        subjectCoordinates = repmat(subjectCoordinates,nFrequencies,1);
        metadata(s).coords.xyz = subjectCoordinates;
    end

    % update filters
    % column filter includes all columns
    metadata(s).filters(2).filter = true(1,size(X,2));
    % anterior filter includes all electrodes with coordinates with a
    % y-value equal to or higher than -23
    anteriorFilter = (subjectCoordinates(:,2)>=-23)';
    metadata(s).filters(5).filter = anteriorFilter;
    % posterior filter includes all electrodes with a y-value lower than
    % -23
    posteriorFilter = (subjectCoordinates(:,2)<-23)';
    metadata(s).filters(6).filter = posteriorFilter;

    % fill in number of columns
    metadata(s).ncol = size(X,2);

    % fill in frequency range
    metadata(s).range = range;

    % fill in wavelet centre 
    metadata(s).waveletCentre = str2double(waveletCentre);

    % save 
    save(metadataRoot,'metadata')

end