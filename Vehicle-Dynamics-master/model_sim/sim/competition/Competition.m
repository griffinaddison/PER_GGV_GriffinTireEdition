classdef Competition < handle
    properties
        skidpadTrack
        autocrossTrack
        enduranceTrack
        accelTrack
        
        accelCar
        skidpadGGV
        autocrossGGV
        enduranceGGV
        
        accelPercent
        
        accel
        skidpad
        autocross
        endurance
        
    end

    methods
        function obj = Competition(varargin)
            p = inputParser;
            p.addOptional('accel', true);
            p.addOptional('skidpad', true);
            p.addOptional('autocross', true);
            p.addOptional('endurance', true);
            p.parse(varargin{:});
            obj.accel = p.Results.accel;
            obj.skidpad = p.Results.skidpad;
            obj.autocross = p.Results.autocross;
            obj.endurance = p.Results.endurance;
            obj.skidpadTrack = readTrack('lincoln_skidpad_2019');
            obj.autocrossTrack = readTrack('lincoln_autocross_2019');
            obj.enduranceTrack = readTrack('lincoln_endurance_2019');
            obj.accelTrack = readTrack('accel');
        end

        function [simOut] = simulate(obj, varargin)
            p = inputParser;
            p.addOptional('display', false);
            p.parse(varargin{:});
            
            if obj.accel
                if p.Results.display
                    disp('Simulating accel...');
                end
                obj.accelCar.init('weightTransfer', 'numeric', 'useWheelVelocity', true);
                accelResults = obj.accelSim(obj.accelCar);
                accelResults.cones = 0;
            else
                accelResults = [];
            end
            
            if obj.skidpad
                if p.Results.display
                    disp('Simulating skidpad...');
                end
                [skidpadResults, skidpadTimes] = obj.multilapSim(obj.skidpadGGV, obj.skidpadTrack, [0, 1]);
                skidpadResults.rawTime = skidpadTimes(2) / 2; 
                skidpadResults.cones = 0;
            else
                skidpadResults = [];
            end

            if obj.autocross
                if p.Results.display
                    disp('Simulating autocross...');
                end
                autocrossResults = obj.multilapSim(obj.autocrossGGV, obj.autocrossTrack, [0]);
                autocrossResults.cones = 0;
                autocrossResults.offCourse = 0;
            else
                autocrossResults = [];
            end

            if obj.endurance
                if p.Results.display
                    disp('Simulating endurance...');
                end
                enduranceResults = obj.multilapSim(obj.enduranceGGV, obj.enduranceTrack, ...
                    [0 1 1 1 1 1 1 0 1 1 1 1 1 1 1]);
                enduranceResults.cones = 3;
                enduranceResults.offCourse = 5;
                enduranceResults.penalty = 0;
            else
                enduranceResults = [];
            end

            dynamicEvents = struct('accel', accelResults, ...
                                   'skidpad', skidpadResults, ...
                                   'autocross', autocrossResults, ...
                                   'endurance', enduranceResults);
            
            scores = computeCompetitionScores(dynamicEvents);

            simOut.dynamicEvents = dynamicEvents;
            simOut.scores = scores;
        end
    end

    methods (Access=protected)
        function [results] = accelSim(obj, accelCar)
            simOut = fullSim('car', accelCar, ...
                'v0', 0.01, 'xstop', 75, 'time', 5, ...
                'controller', OldAccelController(obj.accelCar, true), 'display', true);
            
            results.simOut = simOut;
            results.isFinished = true;
            results.rawTime = max([simOut.t]);
        end

        function [results, times] = multilapSim(obj, ggv, track, lapStrategy)
            % lapStrategy is array of the form [0 1 1 1 0 1 1 1]
            % Each entry is a lap, 0 is a start from rest and 1 is a flying start

            if ismember(0, lapStrategy)
                restSimOut = lapSim(ggv, track, 'startVel', 1.001, 'loop', true, 'accelZone', obj.accelPercent);
            end

            if ismember(1, lapStrategy)
                longVelsRest = restSimOut.runData.longVel;
                flyingSimOut = lapSim(ggv, track, 'startVel', longVelsRest(end), 'loop', true, 'accelZone', obj.accelPercent);
            end
            
            times = [];
            totalTime = 0;
            for i = 1:length(lapStrategy)
                if lapStrategy(i) == 0
                    totalTime = totalTime + restSimOut.stats.finishTime;
                    times(end+1) = restSimOut.stats.finishTime; 
                else
                    totalTime = totalTime + flyingSimOut.stats.finishTime;
                    times(end+1) = flyingSimOut.stats.finishTime; 
                end
            end
            
            results.simOut = restSimOut;
            results.isFinished = true;
            results.rawTime = totalTime;
        end
    end
end
