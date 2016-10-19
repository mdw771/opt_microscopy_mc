%% 
% Lists for refractive indices and layer boundary positions follow the
% following format:
% n = [amb.n, n1, n2, ..., amb.n];
% z = [0, z1, z2, z3, ..., z_n].
% Layers are indiced in such a way that layer 1 corresponds to the upper
% ambience, and the last index corresponds to the lower ambience, i.e., the
% number of layer indices is equal to the length of refractive index list.
%%
% set parameters
clear;
n_ls = [1, 1, 1];
z_ls = [0, 1];
mu_a_ls = [0, 0.1, 0];
mu_s_ls = [0, 100, 0];
g_ls = [1, 0.9, 1];
mu_t_ls = mu_a_ls + mu_s_ls;
n_photon = 1000;
w_thresh = 0.0001;
m = 10;

x=[];
y=[];
z=[];
w=[];

% start loop
for i_photon = 1:n_photon
    i_photon
    % initialize
    ph = photon();
    ph = ph.initialize(0, 0);

    while ~(ph.dead)
        
        % set new s if s = 0
        if ph.s == 0
            ph = ph.get_s();
        end

        % check boundary and move
        ph = ph.move(z_ls, mu_t_ls);

        % if no booundary hit, absorb and scatter
        if ph.s == 0
            ph = ph.absorb(mu_a_ls, mu_s_ls);
            ph = ph.scatter(g_ls);
            %
            x(i_photon, ph.scatters) = ph.x;
            y(i_photon, ph.scatters) = ph.y;
            z(i_photon, ph.scatters) = ph.z;
            w(i_photon, ph.scatters) = ph.w;
            %
        % if boundary hit, transmit or reflect
        else
            ph = ph.reflect_transmit(n_ls);
        end

        % if photon is alive but low in weight, run roulette
        if ~(ph.dead)
            if ph.w < w_thresh
                ph = ph.terminate(m);
            end
        end
        
    end
        
end
