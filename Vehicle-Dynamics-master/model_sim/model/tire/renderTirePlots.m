function createTirePlots(varargin)
    p = inputParser;
    p.addRequired('tireModel1');
    p.addOptional('tireModel2', []);
    p.addOptional('normalLoads', [222, 667, 1112]); %Set normal loads
    p.addOptional('plotCoefficient', true);
    p.addParameter('makeSubPlots', true);
    p.parse(varargin{:});
    
    set(0, 'DefaultLineLineWidth', 3);
    
    % Load and filter test data
    if ~p.Results.plotCoefficient
        load('18R25Brun39_SL_F.mat', 'data')
        dataX = data;
        indFzX = dataX.Fz > 225 & dataX.Fz < 1600;
        indSA1 = rad2deg(dataX.SA) > -0.25 & rad2deg(dataX.SA) < 0.25;
        indSA2 = rad2deg(dataX.SA) > -3.25 & rad2deg(dataX.SA) < -2.75;
        indSA3 = rad2deg(dataX.SA) > -6.25 & rad2deg(dataX.SA) < -5.75;
        filtX = indFzX & indSA1;
    end
    
    load('16R25Brun6_F.mat', 'data')
    dataY = data;
    indFzY = dataY.Fz > 200 & dataY.Fz < 1150;
    filtY = indFzY;
    
    pg = PlotGroup('makeSubPlots', p.Results.makeSubPlots, ...
                   'rows', 1, 'cols', 2);
               
    tm1 = p.Results.tireModel1;
    hasTwoTires = ~isequal(p.Results.tireModel2, []);
    if hasTwoTires
        tm2 = p.Results.tireModel2;
    end

    function handleLoadPlots(forcePlot)
        for fz = p.Results.normalLoads
            forcePlot(tm1, fz, '-');
        end

        if hasTwoTires
            set(gca,'ColorOrderIndex',1)
            for fz = p.Results.normalLoads
                forcePlot(tm2, fz, '--');
            end
        end
        legend('Test Data', '50lbs', '150lbs', '250lbs')
%         legend = {};
%         for fz = p.Results.normalLoads
%             legend{end+1} = strcat(num2str(fz), 'lbs');
%         end
%         if hasTwoTires
%             for fz = p.Results.normalLoads
%                 legend{end+1} = strcat(num2str(fz), 'N M2');
%             end
%         end
%         pg.handleLegend(legend);
    end

    % Plot longitudinal forces
    pg.handleFigure();
    if ~p.Results.plotCoefficient
        pg.createStaticPlot(dataX.SR(filtX), dataX.Fx(filtX),'o');
    end
    srs = -0.23:0.01:0.5;
    
    function [fx] = getFx(tm, Fz, sr)
        [~, F] = tm.compute({}, Fz, deg2rad(0), sr, 11);
        fx = F(1);
    end
    grid on
    function plotFx(tm, Fz, linestyle)
        fx = arrayfun(@(sr) getFx(tm, Fz, sr), srs);
        if p.Results.plotCoefficient
            pg.createStaticPlot(srs, fx / Fz, linestyle, 'linewidth', 2);
            xlabel('Slip Ratio');
            ylabel('μx');
            title('[Old Model] μx vs Slip Ratio for Different Normal Loads');          
        else
            pg.createStaticPlot(srs, fx/0.6, linestyle, 'linewidth', 2);
            xlabel('Slip Ratio');
            ylabel('Fx - Longitudinal Force [N]');
            title('[Old Model] Fx vs Slip Ratio, 0 Slip Angle');
        end
    end
    
    handleLoadPlots(@plotFx);

    
    % Plot lateral forces
    pg.handleFigure();
    if ~p.Results.plotCoefficient
        pg.createStaticPlot(dataY.SA(filtY), dataY.Fy(filtY),'o');
    end
    sas = -0.23:0.01:0.5;

    function [fy] = getFy(tm, Fz, sa)
        [~, F] = tm.compute({}, Fz, sa, 5, 11);
        fy = F(2);
    end
    grid on
    function plotFy(tm, Fz, linestyle)
        fy = arrayfun(@(sa) getFy(tm, Fz, sa), sas);
        if p.Results.plotCoefficient
            pg.createStaticPlot(sas, fy / Fz, linestyle);
            xlabel('Slip Angle');
            ylabel('μy');
            title('[Old Model] μy vs Slip Angle for Different Normal Loads');       
        else
            pg.createStaticPlot(sas, fy/0.6, linestyle);
            xlabel('Slip Angle');
            ylabel('Fy - Lateral Force [N]');
            title('[Old Model] Fy vs Slip Angle');
        end
    end
    
    handleLoadPlots(@plotFy);


end
