classdef Animator < handle
    properties
        figure
    end
    
    methods (Abstract)
        init(obj, figure)
        render(obj, state, time)
    end
end

