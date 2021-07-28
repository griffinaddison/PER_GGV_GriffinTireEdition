classdef Component < handle
    % Component a base class for modelling any kind of car component
    properties
        % Internal, time-varying states related to a component
        % For example, this might be temperature for a motor
        stateDescriptor @ Descriptor
    end
    
    methods (Abstract)
        compute(obj, state, varargin)
    end

    methods
        function obj = Component(varargin)
            p = inputParser;
            p.addOptional('stateDescriptor', Descriptor({}));
            p.parse(varargin{:});

            obj.stateDescriptor = p.Results.stateDescriptor;
        end
    end
end
