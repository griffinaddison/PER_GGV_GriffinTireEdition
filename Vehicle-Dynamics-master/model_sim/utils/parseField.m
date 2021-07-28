function values = parseField(varargin)
    p = inputParser;
    p.addRequired('structs');
    p.addRequired('fieldName');
    p.addOptional('fieldIndex', 1);
    p.parse(varargin{:});

    structs = p.Results.structs;
    fieldName = p.Results.fieldName;
    fieldIndex = p.Results.fieldIndex;

    % Takes nd array of struct and converts them into values matrix of field
    values = zeros(size(structs));

    for i = 1 : numel(structs)
        field = structs{i}.(fieldName);
        values(i) = field(fieldIndex);
    end
end
