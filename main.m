%% 
% Lists for refractive indicesm layer boundary positions, and booleans 
% indicating whether the layer is clear or not, follow the shown format:
% n = [amb.n, n1, n2, ..., amb.n];
% z = [0, z1, z2, z3, ..., z_n];
% clear_ls = [true, true/false, true/false, ..., true],
% Layers are indiced in such a way that layer 1 corresponds to the upper
% ambience, and the last index corresponds to the lower ambience, i.e., the
% number of layer indices is equal to the length of refractive index list.

%%
% set parameters
clear;
ly1 = layer(-1, 0, 0, 0, 1, 1, true, true);
ly2 = layer(0, 1, 0.1, 100, 0.9, 1, false, false);
ly3 = layer(1, inf, 0, 0, 1, 1, true, true);
ly_ls = [ly1, ly2, ly3];
n_photon = 1000;
w_thresh = 0.0001;
m = 10;
n_r = 500; % number of grid pixels along r
n_z = 200; % number of grid pixels along z
delta_z = (z_ls(end)-z_ls(1)) / n_z;
delta_r = 0.005;

%%
% set recording grids
a_rz = zeros([n_r, n_z]);


x=[];
y=[];
z=[];
w=[];

% start loop
for i_photon = 1:n_photon
    
    waitbar(i_photon/n_photon)
    
    % initialize
    ph = photon();
    ph = ph.initialize(0, 0, ly_ls);

    while ~(ph.dead)
        
        % set new s if s = 0
        if ph.s == 0
            ph = ph.get_s();
        end

        % check boundary and move
        ph = ph.move(ly_ls);

        % if no booundary hit, absorb and scatter
        if ph.s == 0
            ph = ph.absorb(ly_ls);
            ph = ph.scatter(g_ls);
            %
            x(i_photon, ph.scatters) = ph.x;
            y(i_photon, ph.scatters) = ph.y;
            z(i_photon, ph.scatters) = ph.z;
            w(i_photon, ph.scatters) = ph.w;
            %
        % if boundary hit, transmit or reflect
        else
            ph = ph.reflect_transmit(ly_ls);
        end

        % if photon is alive but low in weight, run roulette
        if ~(ph.dead)
            if ph.w < w_thresh
                ph = ph.terminate(m);
            end
        end
        
    end
        
end
