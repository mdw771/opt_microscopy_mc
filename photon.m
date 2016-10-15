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
end

