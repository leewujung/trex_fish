% 2018 01 17  Calculate expansion and shrinking speed of fish
%             aggregation


clear

addpath('~/code_matlab_dn/saveSameSize');
addpath(['~/code_git/trex_fish/Triplet_processing_toolbox'])
base_save_path = '~/internal_2tb/trex/figs_results/';
base_data_path = '~/internal_2tb/trex/figs_results/';

% Set up various paths
data_path = 'subset_beamform_cardioid_coherent_run131';
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Ping range
ping_all = 1:2:1000;  % use LF waveform
plot_opt = 0;

% Set params
cmap = 'jet';
sm_len = 1;
npt = 50;
win_perc = 0.2;  % proportion of total signal length to form a window for
                 % spectral estimation
axis_lim = [-5 -1 -5 -1];
color_axis = [180 210];


% Load 1 file to calculate location params
scat_fname = sprintf('%s_ping%04d.mat',data_path,1);
A = load(fullfile(base_data_path,data_path,scat_fname));


% Marks and directions for fish expansion and contraction
wr_ctr = [-2.749, -2.948];   % center of wreck
dl.a = 45;   % [deg] degree from +x-axis
dl.r_total = 1.6;  % [km] range from center of wreck
dl.unit_vec = [cos(dl.a/180*pi),sin(dl.a/180*pi)];
dl.end = wr_ctr + 1.5*[cos(dl.a/180*pi),sin(dl.a/180*pi)];

dl.r_vec = 0:mean(diff(A.data.range_beam)):dl.r_total;
dl.xy_vec = repmat(wr_ctr,length(dl.r_vec),1) +...
                        dl.r_vec'*[cos(dl.a/180*pi),sin(dl.a/180*pi)];
[I,xy_loc,r_proj] = get_xyloc_along_line(A,sm_len,wr_ctr,dl);


fig = figure('position',[300 60 1000 500]);
corder = get(gca,'colororder');
for iP=1:length(ping_all)

    % Load file and set filename
    ping_num = ping_all(iP);
    scat_fname = sprintf('%s_ping%04d.mat',data_path,ping_num);
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num);
    disp(['Processing ',scat_fname])
    A = load(fullfile(base_data_path,data_path,scat_fname));

    % Calculate echo level by 1D interpolation along the specified
    % direction. Range from xy_loc to wr_ctr calculated by projection.
    echo_level(iP,:) = get_echo_level_along_line(A,sm_len,I,r_proj,dl);

end



%for iP=1:length(ping_all)
%    el_sm(iP,:) = smooth(echo_level(iP,:),10);    
%end