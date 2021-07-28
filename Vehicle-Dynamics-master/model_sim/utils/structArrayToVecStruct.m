function vecStruct = structArrayToVecStruct(structArray)
    fields = fieldnames(structArray);
    vecStruct = {};
    for i = 1 : numel(fields)
        field = fields{i};
        vecStruct.(field) = [structArray.(field)].';
    end
end
