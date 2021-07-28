classdef Descriptor < handle
    % Descriptor an abstract container describing a set of variables
    properties
        descriptor % cell array with var names and elem counts
    end

    methods
        function [obj] = Descriptor(varargin)
            % descriptor: cell array with variable names and then number of
            % elements in state vector for each variable
            % e.g.: {'x', 1, 'xdot', 1, 'w', 4}
            % Would encode an x position, velocity, and 4 wheel velocities
            p = inputParser;
            p.addRequired('descriptor');
            p.parse(varargin{:});
            
            assert(isempty(p.Results.descriptor) || isvector(p.Results.descriptor), ...
                'Descriptor must be a vector');
            assert(mod(length(p.Results.descriptor), 2)==0, ...
                'Descriptor array must be even length');

            for i = 1:2:length(obj.descriptor)
                assert(ischar(obj.descriptor{i}), ...
                    'Descriptor array must contain name-length pairs');
                assert(floor(obj.descriptor{i+1}) == floor(obj.descriptor{i+1}), ...
                    'Descriptor array must contain name-length pairs');
            end

            obj.descriptor = p.Results.descriptor;
        end

        % Turns a vector into a struct
        % e.g. if your descriptor is {'x', 1, 'w', 2}
        % The packed vector is [3,5,6] -> unpacked struct with fields x=3 and w=[5,6]
        function [unpacked] = unpack(obj, packed)
            assert(size(packed, 2) == obj.packedLength(), ...
                'Num columns in packed vec must equal number of things to unpack');

            unpacked = struct();
            unpackedIndex = 1;
            for i = 1:2:length(obj.descriptor)
                name = obj.descriptor{i};
                count = obj.descriptor{i+1};
                % packed can actually have multiple rows
                % used for efficiently processing multiple
                % instances of packed data
                unpacked.(name) = packed(:, unpackedIndex : ...
                                     unpackedIndex + (count - 1));
                unpackedIndex = unpackedIndex + count;
            end
        end
       
        % Turns a struct into a vector
        % e.g. if your descriptor is {'x', 1, 'w', 2}
        % The packed vector is [3,5,6] -> unpacked struct with fields x=3 and w=[5,6]
        function [packed] = pack(obj, unpacked)
            packed = [];
            packedIndex = 1;
            for i = 1:2:length(obj.descriptor)
                name = obj.descriptor{i};
                count = obj.descriptor{i+1};
                packedRange = packedIndex : packedIndex + (count - 1);
                packed(:, packedRange) = unpacked.(name);
                packedIndex = packedIndex + count;
            end
        end

        function [packedLength] = packedLength(obj)
            packedLength = 0;
            for i = 1:2:length(obj.descriptor)
                packedLength = packedLength + obj.descriptor{i+1};
            end
        end
    end
end
