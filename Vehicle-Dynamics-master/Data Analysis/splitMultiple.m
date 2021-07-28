function splits = splitMultiple(messages, IDs, starts, ends)

    for i = 1:length(starts)
       
        splits{i} = splitLogsPCMTime(messages, IDs, starts(i), ends(i));
        
    end

end