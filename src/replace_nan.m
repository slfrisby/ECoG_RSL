function S = replace_nan(S)
% replace NaNs caused by the model predicting the same coordinate for every
% item. Used calculate_fold_by_fold_correlations.m .

    % if the input is a struct
    if isstruct(S)
        % get the field names in the struct
        fields = fieldnames(S);
        % for each field
            for f = 1:numel(fields)
                % find out whether that field is a struct or is data,
                % and replace the nans
                S.(fields{f}) = replace_nan(S.(fields{f}));
            end
    % if the input is a data matrix
    elseif isnumeric(S)
        % get rid of the nans
        S(isnan(S)) = 0;
    end
end