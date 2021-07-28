classdef CarModel < handle & matlab.mixin.Copyable
    properties
        % Aggregates the states of the car and the components
        stateCollector @ DescriptorCollector

        params % A struct of car parameters
        baseStateDescriptor @ Descriptor % car's state descriptor
        controlDescriptor @ Descriptor % descriptor for the control inputs

        components
        inited
    end

    methods (Abstract, Access=protected)
        doInit(obj, varargin)
        % state: state struct, dictated by subclass
        % control: optional struct with control inputs
        % Output: state time derivative struct, debug struct
        computeDynamics(obj, state, control)
    end

    methods
        function obj = CarModel(varargin)
            p = inputParser;
            % Struct of parameters
            p.addRequired('params'); 
            % Descriptor for state variables of the car (not components)
            p.addRequired('baseStateDescriptor');
            % Same format as baseStateDescriptor, except for controller
            p.addRequired('controlDescriptor');
            % A cell array of components
            p.addRequired('components');

            p.parse(varargin{:});
            
            res = p.Results;
            obj.params = res.params;
            obj.baseStateDescriptor = res.baseStateDescriptor;
            obj.controlDescriptor = res.controlDescriptor;

            stateDescriptors = {obj.baseStateDescriptor};
            for component = res.components
                stateDescriptors{end+1} = component{1}.stateDescriptor;
            end
            obj.stateCollector = DescriptorCollector(stateDescriptors);

            obj.inited = false;
        end

        function obj = init(obj, varargin)
            obj.doInit(varargin{:});
            obj.inited = true;
        end

        % state: state vector, dictated by subclass
        % control: optional vector with control inputs
        % Output: state time derivative vector, debug struct
        function [statedot, debug] = dynamics(obj, state, control)
            assert(obj.inited, 'Must call init before dynamics');
            state = obj.stateCollector.unpack(state);
            control = obj.controlDescriptor.unpack(control);
            [statedot, debug] = obj.computeDynamics(state, control);
            statedot = obj.stateCollector.pack(statedot);
            if ~iscolumn(statedot)
                statedot = statedot.';
            end
        end
    end
end
