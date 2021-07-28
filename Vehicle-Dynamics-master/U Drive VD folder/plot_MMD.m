function [ handles ] = plot_MMD( mmd, figureNum, debug )
%% Assume that user inputs consistent MMDs (i.e. all CN_Ay)

n = length(mmd);

xaxislabel = cell(n,1);
yaxislabel = cell(n,1);
zaxislabel = cell(n,1);
titlelabelpostfix = cell(n,1);

for ii = 1:n
    if (strcmp(mmd(ii).type, 'CN_Ay'))
        xaxislabel{ii} = 'Lateral Acceleration (Ay)';
        yaxislabel{ii} = 'Yaw Moment Coefficient (CN)';
        zaxislabel{ii} = 'Longitudinal Acceleration (Ax)';
    elseif (strcmp(mmd(ii).type, 'CN_CY'))
        xaxislabel{ii} = 'Normalized Lateral Force (Ay)';
        yaxislabel{ii} = 'Yaw Moment Coefficient (CN)';
        zaxislabel{ii} = 'Normalized Longitudinal Force (Ax)';
    end

    if (strcmp(mmd(ii).constant, 'speed'))
        titlelabelpostfix{ii} = ['Velocity = ' num2str(mmd(ii).env.V) ' m/s'];
    elseif (strcmp(mmd(ii).constant, 'radius'))
        titlelabelpostfix{ii} = ['Radius = ' num2str(mmd(ii).env.R) ' m'];
    elseif (strcmp(mmd(ii).constant, 'omega'))
        titlelabelpostfix{ii} = ['Yaw Rate = ' num2str(mmd(ii).env.omega) ' deg/s'];
    end
end

colors = ['b', 'r', 'k', 'g', 'm'];

% for now assume consistency
figure(figureNum); clf;
suptitle(['Output, ' titlelabelpostfix{1}]);

nsr = 7;
nsc = 4;
plot_grid = reshape(1:nsr*nsc, nsr, nsc);
plot_grid_occupied = zeros(size(plot_grid));


if (debug > 0)
    % Tire Info
    subplot(nsr,nsc,1); hdi = plot(mmd(1).data(:,3:6), '.-');    ylabel('\delta_i'); legend('RL', 'RR', 'FL', 'FR');
    subplot(nsr,nsc,2); hbi = plot(mmd(1).data(:,7:10), '.-');   ylabel('\beta_i'); 
    subplot(nsr,nsc,3); hai = plot(mmd(1).data(:,11:14), '.-');  ylabel('\alpha_i');
    subplot(nsr,nsc,4); hnci = plot(mmd(1).data(:,19:22), '.-'); ylabel('no contact_i');

    % Tire forces and moments
    subplot(nsr,nsc,5); hfzi = plot(mmd(1).data(:,15:18), '.-'); ylabel('F_{z,i}^b');
    subplot(nsr,nsc,6); hfxi = plot(mmd(1).data(:,27:30), '.-'); ylabel('F_{x,i}^b');
    subplot(nsr,nsc,7); hfyi = plot(mmd(1).data(:,23:26), '.-'); ylabel('F_{y,i}^b');
    subplot(nsr,nsc,8); hmzi = plot(mmd(1).data(:,31:34), '.-'); ylabel('M_{z,i}^b');

    % Body forces and moments
    subplot(nsr,nsc,9); hfxb = plot(mmd(1).data(:,35), '.-'); ylabel('F_x^b');
    subplot(nsr,nsc,10); hfyb = plot(mmd(1).data(:,36), '.-'); ylabel('F_y^b');
    subplot(nsr,nsc,11); hmzb = plot(mmd(1).data(:,37), '.-'); ylabel('M_z');
    subplot(nsr,nsc,12); hmwc = plot(mmd(1).data(:,41), '.-'); ylabel('\omega');

    % Velocity Frame Outputs
    subplot(nsr,nsc,16); haxv = plot(mmd(1).data(:,38), '.-'); ylabel('A_x^v');
    subplot(nsr,nsc,20); hayv = plot(mmd(1).data(:,39), '.-'); ylabel('A_y^v');
    subplot(nsr,nsc,24); hcnv = plot(mmd(1).data(:,40), '.-'); ylabel('CN^v');

    % Residual
    subplot(nsr,nsc,28); hres = semilogy(abs(mmd(1).data(:,43)), '.-'); ylabel('Conv Crit');

    set(findobj('type','axes'),'xgrid','on','ygrid','on');
    drawnow();
    
    
    % Plot Traditional MMD
    subplot(nsr,nsc,[13 14 15 17 18 19 21 22 23 25 26 27]);
    hold on;
    grid on;
else
    % Plot Traditional MMD
    subplot(nsr,nsc,plot_grid(~plot_grid_occupied));
    hold on;
    grid on;
end



for ii = 1:n
    % Lines of constant steer are in rows, i.e. AY(11,:)
    mmd(ii).hsteer = plot3(mmd(ii).AY(1,:), mmd(ii).CN(1,:), mmd(ii).AX(1,:), ['--' colors(ii)], 'LineWidth',1);
    plot3(mmd(ii).AY(1:end,:)', mmd(ii).CN(1:end,:)', mmd(ii).AX(1:end,:)', ['--' colors(ii)], 'LineWidth',1);
   % Lines of constant vehicle slip are in columns, i.e. AY(:,11)
    mmd(ii).hslip = plot3(mmd(ii).AY(:,1), mmd(ii).CN(:,1), mmd(ii).AX(:,1), ['-' colors(ii)], 'LineWidth',1);
    plot3(mmd(ii).AY(:,1:end), mmd(ii).CN(:,1:end), mmd(ii).AX(:,1:end), ['-' colors(ii)], 'LineWidth',1);
end

legendhandles = [];
legendentries = {};
for ii = 1:n
    legendhandles = [legendhandles, mmd(ii).hslip, mmd(ii).hsteer];
    legendentries = [legendentries, {[mmd(ii).car.name ' - Constant Vehicle Slip'], [mmd(ii).car.name ' - Constant Steer']}];
end

legend(legendhandles, legendentries);

ii = 1;
xlabel(xaxislabel{ii});
ylabel(yaxislabel{ii});
zlabel(zaxislabel{ii});


end

