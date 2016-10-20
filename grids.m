classdef grids
    properties
        a_rz
        a_1st
        delta_r
        delta_z
    end
    methods
        function obj = grids(nr, delta_r, nz, delta_z)
            obj.a_rz = zeros([nr, nz]);
            obj.a_1st = zeros(nz);
            obj.delta_r = delta_r;
            obj.delta_z = delta_z;
        end
        function obj = update_a(ph, dw)
            r = sqrt(ph.x^2 + ph.y^2);
            z = ph.z;
            if ph.scatters ~= 0
                ir = r/obj.delta_r + 1;
                iz = z/obj.delta_z + 1;
                obj.a_rz(ir, iz) = obj.a_rz(ir, iz) + dw;
            else
                iz = z/obj.delta_z + 1;
                obj.a_1st(iz) = obj.a_1st(iz) + dw;
            end
        end
    end
end