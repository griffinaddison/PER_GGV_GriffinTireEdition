data = csvread('../../resources/data/relevant/testing/autocross_energy_data_06_14_19.csv', 1, 0);

% Grab data from one autoX run
data = data(all(data,2),:); % Remove rows with zeros
data = data(260:end, :);

% Ignore duplicate timestamps
[~, ia, ~] = uniquetol(data(:, 1), 1e-4);
data = data(ia, :);

time = data(:, 1) - data(1, 1);
remaining_capacity = data(:, 2);
state_of_charge = data(:, 3);
voltage = data(:, 4);
energy = voltage .* remaining_capacity;
xaccel = data(:, 5);
yaccel = data(:, 6);
lat = data(:, 7);
long = data(:, 8);
xvel = data(:, 9);
yvel = data(:, 10);
[x, y] = grn2eqa(lat, long, [lat(1), long(1)], referenceEllipsoid('earth'));
dist = cumsum(hypot(diff(x), diff(y)));

laps = [];

lap_start_pos = [0, 0];
lap_start_index = 1;
for i = 1:length(data)
    cur_pos = [x(i), y(i)];
    cur_time = time(i);

    if norm(cur_pos - lap_start_pos) < 7 ...
        && cur_time - time(lap_start_index) > 25
        if cur_time - time(lap_start_index) < 50
            laps = [laps ; lap_start_index, i];
        end
        lap_start_index = i+1;
    end
end

times = [];
startcharges = [];
chargediffs = [];
for lap=laps.'
    times = [times; time(lap(2)) - time(lap(1))];

    %startcharges = [startcharges; state_of_charge(lap(1))];
    %chargediffs = [chargediffs; state_of_charge(lap(1)) - state_of_charge(lap(2))];

    lap_voltage = mean(voltage(lap(1):lap(2)));
    startcharges = [startcharges; remaining_capacity(lap(1)) * lap_voltage];
    chargediffs = [chargediffs; (remaining_capacity(lap(1)) - remaining_capacity(lap(2))) * lap_voltage];
end

%{
delta_charge = -[0; diff(state_of_charge)];
fwd_accel = xvel >= 0 & xaccel >= 0 & delta_charge < 2e-3;
scatter(xvel(fwd_accel), delta_charge(fwd_accel), 60, state_of_charge(fwd_accel) * 5500, 'filled');
xlabel('X velocity');
ylabel('Loss in pack energy (wH)');

cb = colorbar;
ylabel(cb, 'Starting lap charges (percentage)');
%}
%
delta_charge = -[0; diff(state_of_charge) ./ hypot(diff(x), diff(y))];
fwd = xvel > 1 & xaccel > 1e-2 & delta_charge < 2e-3;
increment = 0.2;
hold on
for pack_soc=0.2:increment:1 - increment
    select = fwd & state_of_charge >= pack_soc & state_of_charge <= pack_soc + increment;
    xvel_sel = xvel(select);
    dc_sel = delta_charge(select);
    coefs = polyfit(xvel_sel, dc_sel, 1);
    xfit = linspace(min(xvel_sel), max(xvel_sel), 100);
    yfit = polyval(coefs, xfit);

   % scatter(xfit, yfit, 60, pack_soc * ones(size(xfit)), 'filled');
    
    scatter(xvel_sel, dc_sel, 60, pack_soc * ones(size(xvel_sel)), 'filled');
end
xlabel('X velocity (m/s)');
ylabel('Loss in pack energy / m (wH / m)');

cb = colorbar;
ylabel(cb, 'Starting lap charges (percentage)');

%{
scatter(times * 22000 / 355, chargediffs * 22000 / 355, 60, 'filled');
xlabel('Endurance time (s)');
ylabel('Percent charge usage');
title('Percent charge usage vs endurance time');

set(gcf,'color','w');
set(gca, 'FontSize', 18);
%}

%{
scatter(times, chargediffs, 60, startcharges, 'filled');
xlabel('Time');
ylabel('Delta charge (wH)');

cb = colorbar;
ylabel(cb, 'Starting lap charges (wH)');
%}

%{
scatter(x, y, 60, state_of_charge, 'filled');
axis equal
xlabel('X position (m)');
ylabel('Y position (m)');

cb = colorbar;
ylabel(cb, 'Longitudinal Velocity (mph)');

d = hypot(diff(x), diff(y));
d_tot = sum(d);
fprintf('Traveled distance: %f\n', d_tot);
fprintf('Time elapsed: %f\n', time(end) - time(1)); 
%}
