function plotMMD(statedots, index)
    yddots = parseField(statedots, 'ydot');
    hddots = parseField(statedots, 'hdot');

    yddots = yddots(index, :, :);
    hddots = hddots(index, :, :);

    scatter(yddots(:), hddots(:));
    xlabel('Lat accel (m/s^2)');
    ylabel('Yaw accel (rad/s^2)');
    grid on
end

