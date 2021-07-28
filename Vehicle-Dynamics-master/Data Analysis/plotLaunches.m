% figure
% hold on
% plotvt(TCtest, 8271); %accel pedal
% %plotvt(TCtest, 8610);
% plotvt(TCtest, 8606); %slip ratio
% plotvt(TCtest, 8251); %torque rq
% plotvt(TCtest, 8601); %ax
% ylim([0 10])
% yyaxis right
% hold on

% plot rear & front wheel speeds for TC
figure
hold on
plotvt(TC2, 8283);
plotvt(TC2, 8285);
title('wheel speeds, TC')

% plot rear &  front wheel speeds for no TC
figure
hold on
plotvt(noTC, 8283);
plotvt(noTC, 8285);
title('wheel speed, no TC');

% plot x acceleration
figure
hold on
correlate(TC2, 8613, 8601);
correlate(noTC, 8613, 8601);
title('x accel');
legend('TC', 'no TC');

%plot slip ratio
figure
hold on
correlate(TC2, 8613, 8606);
correlate(noTC, 8613, 8606);
title('Slip Ratio')
legend('TC', 'noTC')
xlabel('Distance Traveled, m')
ylabel('Slip Ratio, -')

%plot torque request
figure
hold on
correlate(TC2, 8613, 8251);
correlate(noTC, 8613, 8251);
legend('TC', 'no TC')
ylabel('Torque command')
xlabel('Distance, m')
