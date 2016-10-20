classdef layer
    properties
        z0, z1
        mu_a, mu_s, mu_t
        g
        n
        clear
        ambient
    end
    methods
        function obj = layer(z0, z1, mu_a, mu_s, g, n, clear, ambient)
            obj.z0 = z0;
            obj.z1 = z1;
            obj.mu_a = mu_a;
            obj.mu_s = mu_s;
            obj.mu_t = mu_a + mu_s;
            obj.g = g;
            obj.n = n;
            obj.clear = clear;
            obj.ambient = ambient;
        end
    end
end