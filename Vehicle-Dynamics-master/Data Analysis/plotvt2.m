function plotvt2(messages, ID1, ID2)
    [ax, h1, h2] = plotyy(messages{ID1}.time, messages{ID1}.val, messages{ID2}.time, messages{ID2}.val);
   % set(ax(1), 'YLim', [0 100]);
   % set(ax(2), 'YLim', [0 5]);
end