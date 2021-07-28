wmax = 2000;
wstep = 100;
r = [];
for w = 0:wstep:wmax
    r = [r; GVK142_025L6(w)];
end
w = 0:wstep:wmax;
h = plotyy( w', r(:,2) ,[w' w' w'],[r(:,1) r(:,3) r(:,4)]*4.448*.0254);
legend('Current','Output Power', 'Power Loss','Power Draw','Location','north')
set(h(2),'YTickLabel',num2str(get(h(2),'YTick')'))
grid on