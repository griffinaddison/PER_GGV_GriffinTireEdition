runOut = readRun('testing_06_15_19', 'autocross');

xvel = runOut.runData.longVel * 2.24;
yvel = runOut.runData.latVel * 2.24;
xaccel = runOut.runData.longAccel / 9.81;
yaccel = runOut.runData.latAccel / 9.81;

% Remove all rows with negative x vel
k = xvel >= 0;
xvel = xvel(k);
yvel = yvel(k);
xaccel = xaccel(k);
yaccel = yaccel(k);

velGroups = linspace(min(xvel), max(xvel), 40);

colors = [zeros(size(velGroups)).', linspace(0, 1, length(velGroups)).', ...
          linspace(1, 0, length(velGroups)).'];

points = [];

for i = 1:length(velGroups) - 1
    vmin = velGroups(i);
    vmax = velGroups(i+1);
    indices = find(xvel > vmin & xvel < vmax);
    
    if ~isempty(indices)
        xvelRange = xvel(indices);
        xaccelRange = xaccel(indices);
        yaccelRange = yaccel(indices);

        nooutliers = rmoutliers([xaccelRange, yaccelRange], 'percentiles', [0, 100]);
        xaccelRange = nooutliers(:, 1);
        yaccelRange = nooutliers(:, 2);
        
        k = boundary(xaccelRange, yaccelRange, 0);

        points = [points; xaccelRange(k), yaccelRange(k), vmin * ones(size(k))];
    end
end

figure
hold on

set(gcf,'color','w');

k = boundary(points);
trisurf(k,points(:,1),points(:,2),points(:,3),'FaceAlpha',1)
colormap winter

xlabel('Longitudinal Acceleration (g)')
ylabel('Lateral Acceleration (g)')
zlabel('Speed (mph)')
set(gca, 'FontSize', 14);

h = get(gca,'DataAspectRatio');
if h(3)==1
      set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
else
      set(gca,'DataAspectRatio',[1 1 h(3)])
end

xlim([-2 2]);
ylim([-2 2]);
