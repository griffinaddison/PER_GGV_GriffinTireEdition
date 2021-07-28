function structArray = vecStructToStructArray(vecStruct)
    fields = fieldnames(vecStruct);

    fieldLength = length(vecStruct.(fields{1}));

    for i = 1 : numel(fields)
        assert(length(vecStruct.(fields{i})) == fieldLength);
    end

    for i = 1 : fieldLength
        for j = 1 : numel(fields)
            field = fields{j};
            structArray(i).(field) = vecStruct.(field)(i);
        end
    end
end
