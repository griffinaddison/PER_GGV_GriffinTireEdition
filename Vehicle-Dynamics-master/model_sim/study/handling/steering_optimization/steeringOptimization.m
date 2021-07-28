generateMMDs = true;

%frontToes = -2.5 : 0.25 : 0;
frontToes = 0;
%rearToes = 0 : 0.1 : 1.5;
%frontToes = -2.0 : 0.25 : 0;
rearToes = -3.0 : 0.5 : 3.0;
%ackermans = 0 : 0.1 : 1;
%ackermans = -1.0 : 0.25 : 1.0;
ackermans = 0;

if generateMMDs
    mmds = {{{}}};
    stats = {{{}}};
    for i = 1 : length(frontToes)
        frontToe = frontToes(i);
        for j = 1 : length(rearToes)
            rearToe = rearToes(j);
            for k = 1 : length(ackermans)
                disp('...')
                ackerman = ackermans(k);

                car = Rev6Full();
                car.params.frontToe = deg2rad(frontToe);
                car.params.rearToe = deg2rad(rearToe);
                car.params.ackerman = ackerman;

                car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
                mmd = createMMD(car, 'v', 15, 'mmdStyle', MMDStyle.Brake);
                mmds{i,j,k} = mmd;
                stats{i,j,k} = calculateMMDStats(mmd);
            end
        end
    end
end

%save('mmds', 'mmds', '-v7.3');
%save('stats', 'stats', '-v7.3');

%load('mmds');
%load('stats');

if false
    figure
    hold on
    clist = colormap(winter(length(ackermans)));
    for i = 1 : length(frontToes)
        frontToe = frontToes(i);
        for j = 1 : length(rearToes)
            rearToe = rearToes(j);
            for k = 1 : length(ackermans)
                ackerman = ackermans(k);
                
                label = sprintf('Toe_f: %f | Toe_r: %f | ackerman: %f', frontToe, rearToe, ackerman);
                renderMMD(mmds{i,j,k}, 'uniformColor', true, ...
                    'color', clist(k, :), 'label', label, 'justHull', true);
            end
        end
    end
    legend
end

if false
    figure
    field = 'control';
    vals = parseField(stats, field);
    surf(rearToes, frontToes, squeeze(vals));
    xlabel('Toe_r');
    ylabel('Toe_f');
    zlabel(field);
    title(field);
end
