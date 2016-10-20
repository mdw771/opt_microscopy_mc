classdef grids
    properties
        a_rz
        a_1st
        delta_r, delta_z
        nr, nz
        rr, zz
    end
    methods
        function obj = grids(nr, delta_r, nz, delta_z)
            obj.a_rz = zeros([nr, nz]);
            obj.a_1st = zeros(nz);
            obj.delta_r = delta_r;
            obj.delta_z = delta_z;
            obj.nr = nr;
            obj.nz = nz;
            obj.rr = nr*delta_r;
            obj.zz = nz*delta_z;
        end
        function obj = update_a(obj, ph, dw)
            r = sqrt(ph.x^2 + ph.y^2);
            z = ph.z;
            ir = floor(r/obj.delta_r) + 1;
            iz = floor(z/obj.delta_z) + 1;
            if r >= obj.rr
                ir = obj.nr;
            end
            if z >= obj.zz
                iz = obj.nz;
            end
            if ph.scatters ~= 0
                obj.a_rz(ir, iz) = obj.a_rz(ir, iz) + dw;
            else
                obj.a_1st(iz) = obj.a_1st(iz) + dw;
            end
        end
        function a_z = get_az(obj)
            a_z = sum(obj.a_rz, 1);
        end
        function phi_z = get_phiz(obj, ly_ls)
            zt = obj.zz;
            layer = 2;
            a_z = obj.get_az();
            phi_z = zeros(obj.nz);
            while zt > 0
                this_ly = ly_ls(layer);
                thickness = this_ly.z1 - this_ly.z0;
                iz0 = floor(this_ly.z0/obj.delta_z) + 1;
                if zt > thickness
                    iz1 = floor(this_ly.z1/obj.delta_z) + 1;
                else
                    iz1 = int16(obj.nz);
                end
                phi_z(iz0:iz1) = a_z(iz0:iz1)/this_ly.mu_a;
                layer = layer + 1;
                zt = zt - thickness;
            end
        end
        function r_coords = get_rcoords(obj)
            i = 1:obj.nr;
            r_coords = ((i+0.5)+1/(12*(i+0.5))) * obj.delta_z;
        end
        function z_coords = get_zcoords(obj)
            i = 1:obj.nz;
            z_coords = (i+0.5) * obj.delta_z;
        end
    end
end