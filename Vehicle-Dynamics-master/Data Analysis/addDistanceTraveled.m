function [IDs, messages] = addDistanceTraveled(IDs, messages, newID)
    
    t = messages{8612}.time;
    v = messages{8612}.val;
    
    dist(1) = 0;
    
    for i = 2:length(v)

        dist(i, 1) = dist(i-1) + (t(i) - t(i-1))*v(i)/1000;
        
    end
    plot(dist)
    distStruct.time = t;
    distStruct.val = dist;
    messages{newID} = [];
    messages{newID} = distStruct;

end