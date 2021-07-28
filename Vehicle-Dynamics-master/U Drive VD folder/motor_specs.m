function motor_specs( motor )
wmax = 1700;
wstep = 10;
r = [];
t = 40/.0254/4.448;%in lb
for w = 0:wstep:wmax
    r = [r; motor(t,w)];
end
w = 0:wstep:wmax;
figure;
[ax, h1, h2] = plotyy( [w' w'], [r(:,2) r(:,4)*4.448*.0254] ,[w' w' w'],[r(:,1) r(:,3) r(:,5)]*4.448*.0254);
legend('Current','Torque','Output Power', 'Power Loss','Power Draw','Location','southoutside')
ylabel('Current (A rms) or Torque (Nm)')
xlabel('rad/s')
axes(ax(2));
title(func2str(motor))

set(ax(2),'YTickLabel',num2str(get(ax(2),'YTick')'))
ylabel('Power (W)')
grid on

end

