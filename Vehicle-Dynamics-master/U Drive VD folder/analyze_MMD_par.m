function [ data ] = analyze_MMD_par( mmd )
    %outputs:
    % max untrimmed Ay  [G]
    %   CN here         [G]
    %   Ax here         [G]
    %   beta here       [deg]
    %   delta here      [deg]
    %   omega here      [deg/s]
    %   radius here     [m]
    %
    % max trimmed Ay    [G]
    %   CN here         [G]
    %   Ax here         [G]
    %   beta here       [deg]
    %   delta here      [deg]
    %   omega here      [deg/s]
    %   radius here     [m]
    %
    %
    % To be added:
    % slope of line of constant slip through origin
    % stability index (slope of line of constant steer through origin)
    % trimmed sideslip
    % understeer gradient
    % steering sensitivity


    s = size(mmd);
    n = length(mmd(:));
    l = size(mmd(1).AY, 1); % number of delta = constant lines
    m = size(mmd(1).AY, 2); % number of beta = constant lines
        
    max_untrimmed_ay = zeros([prod(s), 7]);
    max_trimmed_ay = zeros([prod(s), 7]);
    trimmed_ay = zeros([prod(s), 7, l]);
    
%     plot_MMD(mmd(1), 13, 0);
%     hold on;
    parfor ii = 1:n;
%         [r,c] = ind2sub(s,ii);
        mmdii = mmd(ii);
        
        % Max untrimmed AY is just the max value
        % not fitting a surface to find the actual max is a bit inaccurate
        % but idgaf
        [~,idx] = max(mmdii.AY(:));
        max_untrimmed_ay(ii, :) = [mmdii.AY(idx),...
                                     mmdii.CN(idx),...
                                     mmdii.AX(idx),...
                                     mmdii.betas_actual(idx),...
                                     mmdii.deltas_actual(idx),...
                                     mmdii.AY(idx) .* mmdii.env.g ./ mmdii.env.V,...
                                     rad2deg(mmdii.AY(idx).*mmdii.car.w ./ mmdii.env.V)];


        % for max trimmed AY we can get an interpolant for all the lines of
        % constant steer, and then find their zeros
        % we get the interpolant in 3-D to make it follow the behavior of the
        % line better
        trimmedayii = trimmed_ay(ii,:,:);
        for jj = 1:l
            out = interpNDcurveintercept(2, mmdii.AY(jj,:), mmdii.CN(jj,:), mmdii.AX(jj,:), mmdii.betas_actual(jj,:));
            trimmedayii(1,:,jj) = [out(1),...
                                    out(2),...
                                    out(3),...
                                    out(4),...
                                    mmdii.deltas_actual(jj,1),...
                                    out(1) ./ mmdii.env.V,...
                                    rad2deg(out(1) .* mmdii.car.w ./ mmdii.env.V)];
        end
        
        % if the car is set up neutral/os, then the last constant steer
        % lines may not cross the axis.  need to sweep constant beta as
        % well
        for kk = 1:m
            out = interpNDcurveintercept(2, mmdii.AY(:,kk)', mmdii.CN(:,kk)', mmdii.AX(:,kk)', mmdii.deltas_actual(:,kk)');
            trimmedayii(1,:,l+kk) = [out(1),...
                                      out(2),...
                                      out(3),...
                                      mmdii.betas_actual(1,kk),...
                                      out(4),...
                                      out(1) .* mmdii.env.g ./ mmdii.env.V,...
                                      rad2deg(out(1) .* mmdii.car.w ./ mmdii.env.V)];
        end
        keyboard;
        trimmed_ay(ii,:,:) = trimmedayii;
        [maxtmp,~] = max(trimmedayii(1,1,:));
        max_trimmed_ay(ii,:) = maxtmp;
    end
    
    data.max_untrimmed_ay = max_untrimmed_ay;
    data.max_trimmed_ay = max_trimmed_ay;
    data.trimmed_ay = trimmed_ay;
end


