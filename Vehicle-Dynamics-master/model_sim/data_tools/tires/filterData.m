function [tireData] = filterData(varargin)
    p = inputParser;
    p.addRequired('tireData');
    p.addRequired('channel');
    p.addRequired('filter'); % =, <, >
    p.addRequired('value');
    p.addOptional('eqTolerance', 1.0);
    p.parse(varargin{:});
    
    tireData = p.Results.tireData;
    filter = p.Results.filter;
    value = p.Results.value;
    
    channelData = tireData.(p.Results.channel);

    if strcmp(filter, '=')
        is = abs(channelData - value) < p.Results.eqTolerance;
    elseif strcmp(filter, '<')
        is = channelData - value < 0;
    elseif strcmp(filter, '>')
        is = channelData - value > 0;
    end

    fields = fieldnames(tireData);

    for i = 1 : numel(fields)
        field = fields{i};
        tireData.(field) = tireData.(field)(is);
    end
end
