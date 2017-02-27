% 2017 02 26  Test parameter selection for split-window normalizer


addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
addpath(['~/internal_2tb/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])

% Set up various paths
base_data_path='~/internal_2tb/trex/figs_results/';
base_save_path='~/internal_2tb/trex/figs_results/';
data_path='subset_beamform_cardioid_coherent_run131';

% Run and ping number
ping_num = [13,103,113,261,441,507,651,781,797,813,893]+1;
%ping_num = ping_num(1:2:end);
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Set params
cmap = 'jet';
sm_len = 200;
axis_lim = [-4.5 -1.5 -4.5 -1.5];
ori_caxis = [180 210];
norm_caxis = [7 15];


% Set up figure
fig = figure('position',[280 60 1500 300]);
corder = get(gca,'colororder');

% Loop through each ping
for iP=1:length(ping_num)

    fname = sprintf('%s_ping%04d.mat', data_path,ping_num(iP));
    ping_num_curr = ping_num(iP);
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num_curr);

    disp(['Processing ',fname])
    A = load(fullfile(base_data_path,data_path,fname));
    
    % Plot title
    title_text = sprintf('Run %d, Ping %d, %02d:%02d:%02d',...
                         run_num,ping_num_curr,A.data.time_hh_local,...
                         A.data.time_mm_local,A.data.time_ss_local);

    % Plot raw echogram
    figure(fig)
    h_ori = plot_small_echogram(subplot(151),A,sm_len,ori_caxis,axis_lim);

    % Get normalizer output
    norm_param.sm_len = 100;    % smooth length
    norm_param.aux_m = 100;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    subplot(152)
    h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
    hold on
    set(h_norm,'edgecolor','none');
    axis equal
    colormap(jet)
    caxis(norm_caxis)
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    title(sprintf('sm%d, aux%dm, guard%d',...
                  norm_param.sm_len,norm_param.aux_m,norm_param.guard_num_bw));

    % Get normalizer output
    norm_param.sm_len = 100;    % smooth length
    norm_param.aux_m = 200;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    subplot(153)
    h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
    hold on
    set(h_norm,'edgecolor','none');
    axis equal
    colormap(jet)
    caxis(norm_caxis)
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    title(sprintf('sm%d, aux%dm, guard%d',...
                  norm_param.sm_len,norm_param.aux_m,norm_param.guard_num_bw));

    % Get normalizer output
    norm_param.sm_len = 200;    % smooth length
    norm_param.aux_m = 200;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    subplot(154)
    h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
    hold on
    set(h_norm,'edgecolor','none');
    axis equal
    colormap(jet)
    caxis(norm_caxis)
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    title(sprintf('sm%d, aux%dm, guard%d',...
                  norm_param.sm_len,norm_param.aux_m,norm_param.guard_num_bw));

    % Get normalizer output
    norm_param.sm_len = 100;    % smooth length
    norm_param.aux_m = 300;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    subplot(155)
    h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
    hold on
    set(h_norm,'edgecolor','none');
    axis equal
    colormap(jet)
    caxis(norm_caxis)
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    title(sprintf('sm%d, aux%dm, guard%d',...
                  norm_param.sm_len,norm_param.aux_m,norm_param.guard_num_bw));
    
    mtit(title_text,'fontsize',16);
    
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');
end


