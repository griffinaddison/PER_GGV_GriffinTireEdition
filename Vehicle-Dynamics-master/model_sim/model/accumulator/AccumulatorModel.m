classdef AccumulatorModel < Component
    properties
        maxPower
        maxRegenPower
    end

    methods
        function obj = AccumulatorModel(maxPower, maxRegenPower)
            descriptor = {'energyDelivered', 1, 'energyRegened', 1};
            obj = obj@Component(Descriptor(descriptor));
            obj.maxPower = maxPower;
            obj.maxRegenPower = maxRegenPower;
        end

        function statedot = compute(obj, state, powerDelivered, brake)
            statedot.energyDelivered = powerDelivered;
            if brake > 0
                statedot.energyRegened = obj.maxRegenPower;
            else
                statedot.energyRegened = 0;
            end
        end
    end
end

