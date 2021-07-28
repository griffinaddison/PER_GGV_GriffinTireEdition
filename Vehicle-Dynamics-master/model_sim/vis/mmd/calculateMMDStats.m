function [stats] = calculateMMDStats(mmd)
    yddots = parseField(mmd.statedots, 'ydot');
    hddots = parseField(mmd.statedots, 'hdot');

    [yddotMax, I] = max(yddots(:));
    stats.grip = yddotMax;
    stats.balance = hddots(I);


    zeroSAIndex = find(~mmd.bodySAs);
    smallSAIndex = find(mmd.bodySAs > 0, 1);

    zeroSteerIndex = find(~mmd.steers);
    smallSteerIndex = find(mmd.steers > 0, 1);

    assert(~isempty(zeroSAIndex));
    assert(~isempty(zeroSteerIndex));

    stats.control = hddots(zeroSAIndex, smallSteerIndex) / ...
                    mmd.steers(smallSteerIndex);
    stats.stability = hddots(smallSAIndex, zeroSteerIndex) / ...
                      mmd.bodySAs(smallSAIndex);

    hullYddots = parseField(mmd.hullStatedots, 'ydot');
    hullHddots = parseField(mmd.hullStatedots, 'hdot');

    % Find max steady state lateral accel
    line = createLine([0, 0], [20, 0]);
    polygon = [hullYddots, hullHddots];
    [intersects, k] = intersectLinePolygon(line, polygon);
    stats.steadyGrip = max(intersects(:));
end
