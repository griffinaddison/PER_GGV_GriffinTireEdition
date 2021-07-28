function res = calcSlipRatio(inputs)

%input 1 is front wheel speed
%input 2 is front wheel speed
%input 3 is rear wheel speed
%input 4 is rear wheel speed

    
    res = mean([inputs(3) inputs(4)])/mean([inputs(1) inputs(2)]) - 1;
    if min(inputs) < 3
        res = 0;
    end
end