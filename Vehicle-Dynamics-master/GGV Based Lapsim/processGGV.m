function ggV = processGGV(ggV)

    speeds = unique(ggV.speeds);
    maxLateral = [];
    for i = 1:length(speeds)
        speed = speeds(i);
        indices = ~isnan(ggV.positiveLongAccel(:, i));
        accelerations = ggV.lateralAccelerations(indices, i);
        maxLateral = [maxLateral; max(accelerations)];
    end

    ggV.maxLateral = maxLateral;
    ggV.flattenedSpeeds = speeds;
end