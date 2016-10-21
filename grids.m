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
            if ir > obj.nr || ph.scatters == 0
                ir = obj.nr;
            end
            if iz > obj.nz
                iz = obj.nz;
            end
            obj.a_rz(ir, iz) = obj.a_rz(ir, iz) + dw;
        end
        function a_z = get_az(obj, n_photon)
            a_z = sum(obj.a_rz, 1);
            a_z = a_z / (obj.delta_z*n_photon);
        end
        function phi_z = get_phiz(obj, ly_ls, n_photon)
            zt = obj.zz;
            layer = 2;
            a_z = obj.get_az(n_photon);
            phi_z = zeros(obj.nz);
            if length(ly_ls) == 3
                this_ly = ly_ls(2);
                phi_z = a_z / this_ly.mu_a;
            else
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
        end
        function r_coords = get_rcoords(obj)
            i = 0:obj.nr-1;
            r_coords = ((i+0.5)+1/(12*(i+0.5))) * obj.delta_r;
        end
        function z_coords = get_zcoords(obj)
            i = 0:obj.nz-1;
            z_coords = (i+0.5) * obj.delta_z;
        end
    end
end