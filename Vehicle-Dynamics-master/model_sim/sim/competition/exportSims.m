function [output] = exportSims(varargin)
    p = inputParser;
    p.addRequired('simOuts');
    p.addRequired('cars');
    p.addRequired('carDescriptors');
    p.parse(varargin{:});

    simOuts = p.Results.simOuts;
    cars = p.Results.cars;
    carDescriptors = p.Results.carDescriptors;
        
    Car = cell(length(cars), 1);
    Configuration = cell(length(cars), 1);
    Mass = zeros(length(cars), 1);
    ComD = zeros(length(cars), 1);
    ComH = zeros(length(cars), 1);
    Accel = zeros(length(cars), 1);
    Skidpad = zeros(length(cars), 1);
    Autocross = zeros(length(cars), 1);
    Endurance = zeros(length(cars), 1);
    AccelPoints = zeros(length(cars), 1);
    SkidpadPoints = zeros(length(cars), 1);
    AutocrossPoints = zeros(length(cars), 1);
    EndurancePoints = zeros(length(cars), 1);
    
    for i = 1:length(simOuts)
        Car{i, 1} = carDescriptors{i};
        if strcmp(class(cars{i}.motors{1}),'DeadMotor')
            Configuration{i, 1} = 'RWD';
        else
            Configuration{i, 1} = '4WD';
        end
        Mass(i, 1) = cars{i}.params.mass;
        ComD(i, 1) = cars{i}.params.comDistribution;
        ComH(i, 1) = cars{i}.params.height;
        Accel(i, 1) = simOuts{i}.dynamicEvents.accel.rawTime;
        Skidpad(i, 1) = simOuts{i}.dynamicEvents.skidpad.rawTime;
        Autocross(i, 1) = simOuts{i}.dynamicEvents.autocross.rawTime;
        Endurance(i, 1) = simOuts{i}.dynamicEvents.endurance.rawTime;
        
        AccelPoints(i, 1) = simOuts{i}.scores.accel;
        SkidpadPoints(i, 1) = simOuts{i}.scores.skidpad;
        AutocrossPoints(i, 1) = simOuts{i}.scores.autocross;
        EndurancePoints(i, 1) = simOuts{i}.scores.endurance;
    end
    output = table(Car, Mass, ComD, ComH, Configuration, Accel, Skidpad, Autocross, Endurance, AccelPoints, SkidpadPoints, AutocrossPoints, EndurancePoints);
end