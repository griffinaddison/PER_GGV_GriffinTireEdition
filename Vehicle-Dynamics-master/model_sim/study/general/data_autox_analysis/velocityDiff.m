testing_data = csvread('../../resources/data/testing/autocross_energy_data_06_14_19.csv', 1, 0);

% Grab data from one autoX run
testing_data = testing_data(all(testing_data,2),:); % Remove rows with zeros

% Grab data from one autoX run
testing_data = testing_data(260:end, :);
% Ignore duplicate timestamps
[~, ia, ~] = uniquetol(testing_data(:, 1), 1e-4);
testing_data = testing_data(ia, :);
%testing_data = testing_data(1367:1392, :);
testing_data = testing_data(2207:2253, :);

testing_time = testing_data(:, 1) - testing_data(1, 1);
testing_remaining_capacity = testing_data(:, 2);
testing_state_of_charge = testing_data(:, 3);
testing_voltage = testing_data(:, 4);
testing_energy = testing_voltage .* testing_remaining_capacity;
testing_xaccel = testing_data(:, 5);
testing_yaccel = testing_data(:, 6);
testing_lat = testing_data(:, 7);
testing_long = testing_data(:, 8);
testing_xvel = testing_data(:, 9);
testing_yvel = testing_data(:, 10);
[testing_x, testing_y] = grn2eqa(testing_lat, testing_long, [testing_lat(1), testing_long(1)], referenceEllipsoid('earth'));
testing_dist = cumsum(hypot(diff(testing_x), diff(testing_y)));

sim_data = csvread('../../resources/data/testing/autocross_optimumlap_sim.csv', 68, 0);
sim_xvel = sim_data(:, 1);
sim_time = sim_data(:, 2);
sim_dist = sim_data(:, 3);
sim_yaccel = sim_data(:, 4);
sim_xaccel = sim_data(:, 5);
sim_x = sim_data(:, 24);
sim_y = sim_data(:, 25);

for i = 1:length(sim_x)
    pos = rotMat2D(-2.1) * [sim_x(i); sim_y(i)];
    sim_x(i) = pos(1);
    sim_y(i) = pos(2);
end


plot(sim_dist, [sim_xvel, interp1(testing_dist, testing_xvel(2:end), sim_dist)] * 2.24, 'LineWidth', 3);

xlabel('Elapsed distance (m)');
ylabel('Velocity (mph)');
legend('Simulation', 'Actual');
title('Simulated vs Actual Velocity');
set(gcf,'color','w');
set(gca, 'FontSize', 18);

figure

scatter(testing_x, testing_y, 60, testing_xaccel, 'filled');
axis equal
xlabel('X position (m)');
ylabel('Y position (m)');
title('Actual velocity over track');

cb = colorbar;
ylabel(cb, 'Longitudinal Velocity (mps)');

set(gcf,'color','w');
set(gca, 'FontSize', 18);

fprintf('Total testing distance: %f\n', testing_dist(end));
fprintf('Total testing time: %f\n', testing_time(end)); 

fprintf('Total sim distance: %f\n', sim_dist(end));
fprintf('Total sim time: %f\n', sim_time(end)); 
