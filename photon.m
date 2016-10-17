classdef photon
    properties
        x, y, z
        ux, uy, uz
        w
        dead
        s
        scatters
        layer
    end
    methods
        function obj = init(obj)
            % initialize photon
            obj.x = 0;
            obj.y = 0;
            obj.z = 0;
            obj.ux = 0;
            obj.uy = 0;
            obj.uz = 1;
            obj.w = 1;
            obj.dead = false;
            obj.s = 0;
            obj.scatters = 0;
            obj.layer = 1;
        end
        function obj = get_s(obj)
            % get random s
            xi = time_rand();
            obj.s = -log(xi);
        end
        function [obj, delta_w] = absorb(obj, mu_ratio)
            % deduce weight due to absorption
            delta_w = obj.w * mu_ratio;
            obj.w = obj.w - delta_w;
        end
        function obj = scatter(obj, g)
            % update direction cosines upon scattering
            xi = time_rand();
            if g ~= 0
                cosine = 1 + g^2 - ((1-g^2)/(1-g+2*g*xi))^2;
                cosine = cosine / (2*g);
            else
                cosine = 2*xi - 1;
            end
            theta = acos(cosine);
            xi = time_rand();
            phi = 2 * pi * xi;
            mux = obj.ux;
            muy = obj.uy;
            muz = obj.uz;
            if abs(muz) < 0.99999
                obj.ux = sin(theta)*(mux*muz*cos(phi)-muy*sin(phi));
                obj.ux = obj.ux/sqrt(1-muz^2) + mux*cosine;
                obj.uy = sin(theta)*(muy*muz*cos(phi)+mux*sin(phi));
                obj.uy = obj.uy/sqrt(1-muz^2) + muy*cosine;
                obj.uz = -sin(theta)*cos(phi)*sqrt(1-muz^2) + muz*cosine;
            else
                obj.ux = sin(theta) * cos(phi);
                obj.uy = sin(theta) * sin(phi);
                obj.uz = sign(muz) * cosine;
            end
        end
    end
end

