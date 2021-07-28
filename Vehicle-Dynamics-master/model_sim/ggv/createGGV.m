function [ggv] = createGGV(varargin)
    p = inputParser;
    p.addRequired('car');
    % Coefs and optimized using optimizeTorqueVectoring script
    p.addOptional('driveStyle', struct('fbTransferCoef', 0.25, ...
        'lrTransferCoef', 3.2, 'startPower', 1, 'powerUsage', 1, 'brakeUsage', 1));
    % Whether to optimize velocites to be more spares at higher vs
    p.addOptional('maxVelocity', 40);
    p.addOptional('denseVs', false);
    p.addOptional('display', false);
    p.parse(varargin{:});
    
    car = p.Results.car;
    driveStyle = p.Results.driveStyle;
    
    if ~car.inited
        car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    end
    assert(~car.useWheelVelocity, 'Must init without wheel velocity');

    cp = car.params;
    
    if p.Results.denseVs
        vs = 1 : 2 : p.Results.maxVelocity;
    else
        vs = quadspace(1, p.Results.maxVelocity, 12);
    end
    
    if p.Results.display
        textprogressbar('Creating GGV: ');
    end

    for i = 1:length(vs)
        if p.Results.display 
            textprogressbar(floor((100.0 * i) / length(vs)));
        end
        plane = createGGVPlane(car, vs(i), driveStyle);
        plane.createHull();
        plane.createInterpolants();
        planes(i) = plane;
    end

    if p.Results.display 
        textprogressbar(' Done');
    end
    
    ggv = GGV(vs, planes, car);
end
