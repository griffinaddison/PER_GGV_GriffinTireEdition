car = Rev6Full();
cogHeights = 0.05:0.05:0.5;
simOuts = singleCompParameterSweep(car, 'params', 'height', cogHeights, true);
% scores = [508.322289, 508.322289, 506.951805, 501.276701, 490.953592, 478.423859, ...
%           521.339314, 477.860189, 441.398081, 415.658448];
% figure
% plot(cogHeights, scores);
% xlabel('CG height')
% ylabel('Total score')
% title('Competition parameter sweep')