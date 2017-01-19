%% plot the 360 deg RL to a pi plot with overlaying bathymetry

M2     =  [30.0599; -85.6811]; % GPS location of the array

%% need to convert beam angle to polar definition
polar_angle = mod( 90 - beam_angle, 360);

X = 0.5*r_win'*cos(polar_angle*pi/180);
Y = 0.5*r_win'*sin(polar_angle*pi/180);

% load in bathymetry map and clutter objects
[Map_X,Map_Y,Map_Z,wrecgps] = func_load_map_targets(M2);

figure(30);
Rmax_map = 8000;%sqrt(max( max(X.^2+Y.^2))); Max range for plotting in meters.

func_plot_360beam_bathy(Rmax_map,Map_X,Map_Y,Map_Z,wrecgps,X,Y,ang_int);
