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

% Marks and directions for fish expansion and contraction
wr_center = [-2.749, -2.948];   % center of wreck
direc_a = 45;   % [deg] degree from +x-axis
direc_r = 1.6;  % [km] range from center of wreck
direc_line_end = wr_center + 1.5*[cos(direc_a/180*pi),sin(direc_a/180*pi)];

scat_fname = sprintf('%s_ping%04d.mat',data_path,1);
A = load(fullfile(base_data_path,data_path,scat_fname));

direc_line_r = 0:mean(diff(A.data.range_beam)):direc_r;
direc_line_vec = repmat(wr_center,length(direc_line_r),1) +...
                        direc_line_r'*[cos(direc_a/180*pi),sin(direc_a/180*pi)];;
[I,xy_loc,r_loc] = get_xyloc_along_line(A,sm_len,direc_line_vec,wr_center);


fig = figure('position',[300 60 1000 500]);
corder = get(gca,'colororder');
for iP=1:length(ping_all)

    % Load file and set filename
    ping_num = ping_all(iP);
    scat_fname = sprintf('%s_ping%04d.mat',data_path,ping_num);
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num);
    disp(['Processing ',scat_fname])
    A = load(fullfile(base_data_path,data_path,scat_fname));

    echo_level(iP,:) = get_echo_level_along_line(A,sm_len,I);

    %------- PLOT ------------
    if plot_opt
    title_text = sprintf('Run %d, Ping %d, %02d:%02d:%02d',...
                         run_num,ping_num,A.data.time_hh_local,...
                         A.data.time_mm_local,A.data.time_ss_local);

    % echogram
    h = plot_small_echogram(subplot(121),A,sm_len,color_axis,axis_lim);
    hold on
    plot([wr_center(1) direc_line_end(1)]*1e3,...
         [wr_center(2) direc_line_end(2)]*1e3,'w-')
    hold off

    subplot(122)  % echo level variation along radial
    cla
    he = plot(r_loc,echo_level);
    xlabel('Range from wreck center (km)','fontsize',14)
    ylabel('Echo level (dB SPL)','fontsize',14)
    hold off
    grid
    
    mtit(title_text,'fontsize',16);
    
    %saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
    %    'format','png');
    end

end



for iP=1:length(ping_all)
    el_sm(iP,:) = smooth(echo_level(iP,:),10);
    
end