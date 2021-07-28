classdef DescriptorCollector < handle
    % DescriptorCollector concatenates multiple descriptors
    %   For example, a car state descriptor, motor state descriptors, etc.
    properties
        descriptors
    end

    methods
        function [obj] = DescriptorCollector(descriptors)
            obj.descriptors = descriptors;
        end

        % Turns a vector into a cell array of unpacked structs
        % e.g. if the descriptors are {'x', 1}, {'temp', 1}
        % unpack [4,5] would return:
        % {(struct with field x=4), (struct with field temp=5)}
        function [unpacked] = unpack(obj, packed)
            if iscolumn(packed)
                packed = packed.';
            end
            
            unpacked = {};
            unpackedIndex = 1;
            for i=1:length(obj.descriptors)
                descriptor = obj.descriptors{i};
                unpackedSub = descriptor.unpack(packed(:, unpackedIndex : ...
                                unpackedIndex + descriptor.packedLength() - 1));
                
                unpacked{i} = unpackedSub;

                unpackedIndex = unpackedIndex + descriptor.packedLength();
            end
        end

        % Turns a cell array of unpacked structs into a vector
        % e.g. if the descriptors are {'x', 1}, {'temp', 1}
        % pack {(struct with field x=1), (struct with field temp=1)}
        % would return [4,5]
        function [packed] = pack(obj, unpacked)
            packed = [];
            packedIndex = 1; 
            for i=1:length(obj.descriptors)
                descriptor = obj.descriptors{i};
                packedSub = descriptor.pack(unpacked{i});
                packed(:, packedIndex : packedIndex + length(packedSub) - 1) = packedSub;

                packedIndex = packedIndex + length(packedSub);
            end
        end
    end
end
