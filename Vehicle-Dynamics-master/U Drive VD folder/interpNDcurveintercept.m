function [out] = interpNDcurveintercept(zeroaxis,varargin)
    % x, y, z are parametric data of a curve in 3-space
    % zeroaxis is 1,2,3 depending on which plane we want to intersect

    d = nargin - 1;
    sp = cell(d,1);
    
    m = length(varargin{1});
    t = 1:m;
    
    for ii = 1:d
        sp{ii} = fit(t', varargin{ii}', 'cubicinterp');
        
    end
    
    if (find(diff(sign(varargin{zeroaxis}))))
        idx = find(diff(sign(varargin{zeroaxis})), 1);
        tz = fzero(sp{zeroaxis}, idx);
        out = [cellfun(@feval, sp, repmat({tz}, size(sp))); tz];
    else
%         keyboard;
        out = zeros(d+1,1);
    end
    
%     for ii = 1:d
%         subplot(d,1,ii);
%         hold on; grid on;
%         plot(t, varargin{ii}, '.b');
%         plot(sp{ii},'r');
%         plot(tz, sp{ii}(tz), '+g');
%     end
    
end

