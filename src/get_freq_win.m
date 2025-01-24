function window = get_freq_win(data,timepoint,varargin)
    % get window of time-frequency (power or phase) data:
    %   - for a given set of electrodes
    %   - at a given timepoint
    %   - within a given frequency range

    % Arguments:
    % data = data (items x electrodes x timepoints x frequencies)
    % timepoint = index of timepoint (the time in ms to which each
    % timepoint corresponds is specified earlier, during wavelet
    % convolution)
    % electrodes = logical index of electrodes from which to get data (default = all electrodes in d)
    % frequencies = logical index of frequencies from which to get data (default = all frequencies in
    % d)

    % parse optional inputs
    p = inputParser;
    addParameter(p,'electrodes',true(size(data,2),1));
    addParameter(p,'frequencies',true(size(data,4),1));
    parse(p,varargin{:});
    electrodes = p.Results.electrodes;
    frequencies = p.Results.frequencies;

    % cut out required window of data 
    window = squeeze(data(:,electrodes,timepoint,frequencies));

    % reformat into 2-dimensional matrix (all electrodes for frequency 1,
    % all electrodes for frequency 2, ...)
    window = reshape(window,size(window,1),[]);

end