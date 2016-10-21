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
        function obj = initialize(obj, x, y, ly_ls)
            % initialize photon
            obj.x = x;
            obj.y = y;
            obj.z = 0;
            obj.ux = 0;
            obj.uy = 0;
            obj.uz = 1;
            obj.dead = false;
            obj.s = 0;
            obj.scatters = 0;
            obj.layer = 2;
            % in case that first layer is clear, do reflection
            amb_ly = ly_ls(1);
            this_ly = ly_ls(2);
            bot_ly = ly_ls(3);
            n1 = amb_ly.n;
            n2 = this_ly.n;
            n3 = bot_ly.n;
            if this_ly.clear
                r1 = ((n1 - n2)/(n1 + n2))^2;
                r2 = ((n3 - n2)/(n3 + n2))^2;
                r_sp = r1 + (1-r1)^2*r2/(1-r1*r2);
                obj.w = 1 - r_sp;
            else
                if n1 ~= n2
                    r_sp = ((n1 - n2)/(n1 + n2))^2;
                    obj.w = 1 - r_sp;
                else
                    obj.w = 1;
                end
            end
        end
        function obj = get_s(obj)
            % get random s
            xi = rand();
            obj.s = -log(xi);
        end
        function [obj, delta_w] = absorb(obj, ly_ls)
            % deduce weight due to absorption
            this_ly = ly_ls(obj.layer);
            mu_ratio = this_ly.mu_a/this_ly.mu_t;
            delta_w = obj.w * mu_ratio;
            obj.w = obj.w - delta_w;
        end
        function obj = scatter(obj, ly_ls)
            % update direction cosines upon scattering
            xi = rand();
            this_ly = ly_ls(obj.layer);
            g = this_ly.g;
            if g ~= 0
                cosine = 1 + g^2 - ((1-g^2)/(1-g+2*g*xi))^2;
                cosine = cosine / (2*g);
            else
                cosine = 2*xi - 1;
            end
            theta = acos(cosine);
            xi = rand();
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
            obj.scatters = obj.scatters + 1;
        end
        function obj = move(obj, ly_ls)
            % judge if the photon will hit boundary then move it 
            this_ly = ly_ls(obj.layer);
            mu_t = this_ly.mu_t;
            z_bound = [this_ly.z0, this_ly.z1];
            if obj.uz < 0
                db = (z_bound(1)-obj.z) / obj.uz;
            elseif obj.uz == 0
                db = inf;
            else
                db = (z_bound(2)-obj.z) / obj.uz;
            end
            if db*mu_t <= obj.s
                % hit boundary
                obj.x = obj.x + obj.ux*db;
                obj.y = obj.y + obj.uy*db;
                obj.z = obj.z + obj.uz*db;
                obj.s = obj.s - db*mu_t;
            else
                % does not hit boundary
                obj.x = obj.x + obj.ux*obj.s/mu_t;
                obj.y = obj.y + obj.uy*obj.s/mu_t;
                obj.z = obj.z + obj.uz*obj.s/mu_t;
                obj.s = 0;
            end
        end
        function obj = reflect_transmit(obj, ly_ls)
            % do reflection or transmission
            this_ly = ly_ls(obj.layer);
            a_i = acos(abs(obj.uz));
            n_i = this_ly.n;
            if obj.uz < 0
                next_ly = ly_ls(obj.layer-1);
                dir = -1;
            else
                next_ly = ly_ls(obj.layer+1);
                dir = 1;
            end
            n_t = next_ly.n;
            a_t = asin(n_i*sin(a_i)/n_t);
            if n_i > n_t && a_i > asin(n_t/n_i)
                r = 1;
            else
                r = (sin(a_i-a_t)/sin(a_i+a_t))^2 ;
                r = 0.5 * (r+(tan(a_i-a_t)/tan(a_i+a_t))^2);
            end
            xi = rand();
            if xi <= r
                % internally reflected
                obj.uz = -obj.uz;
            else
                % transmitted
                if dir == -1
                    obj.layer = obj.layer - 1;
                else
                    obj.layer = obj.layer + 1;
                end
                if obj.layer == 1 || obj.layer == length(ly_ls)
                    obj.dead = true;
                else
                    obj.ux = obj.ux*n_i/n_t;
                    obj.uy = obj.uy*n_i/n_t;
                    obj.uz = sign(obj.uz)*cos(a_t);
                end
            end
        end
        function obj = terminate(obj, m)
            xi = rand();
            if xi <= 1/m
                obj.w = m*obj.w;
            else
                obj.w = 0;
                obj.dead = true;
            end
        end
    end
end

