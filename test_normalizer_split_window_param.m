% 2017 02 26  Test parameter selection for split-window normalizer


addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
addpath(['~/internal_2tb/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])

% Set up various paths
base_data_path='~/internal_2tb/trex/figs_results/';
base_save_path='~/internal_2tb/trex/figs_results/';

% Set params
run_num = 87;
if run_num==87
    ping_num = [100,164,183,197,231,462,766,835,873,936];  % run 087
    ori_caxis = [180 210];  % wfm 1 of run 131
elseif run_num==131
    ping_num = [13,103,113,261,441,507,651,781,797,813,893];  % run 131
    if mod(ping_num(1),2)==0
        ori_caxis = [178 208];  % wfm 2 of run 131
    else
        ori_caxis = [180 210];  % wfm 1 of run 131
    end
end

% Set up various paths
data_path = sprintf('subset_beamform_cardioid_coherent_run%03d',run_num);

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Set params
cmap = 'jet';
axis_lim = [-4.3 -1.3 -4.5 -1.5];
norm_caxis = [7 15];
sm_len = 100;

% Set up figure
fig = figure('position',[280 100 900 900]);
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
    h_ori = plot_small_echogram(subplot(321),A,sm_len,ori_caxis,axis_lim);
    title('Raw echogram')
    colorbar

    % Get normalizer output
    norm_param.sm_len = 100;       % smooth length
    norm_param.aux_m = 100;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    plot_normalized_echogram(subplot(323),beamform_norm,meta,norm_caxis,axis_lim);
    tt = title(sprintf('sm%d, aux%dm, guard%d',...
                       norm_param.sm_len,norm_param.aux_m, ...
                       norm_param.guard_num_bw));
    set(tt,'fontsize',12);
    colorbar

    % Get normalizer output
    norm_param.sm_len = 100;    % smooth length
    norm_param.aux_m = 200;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    plot_normalized_echogram(subplot(324),beamform_norm,meta,norm_caxis,axis_lim);
    tt = title(sprintf('sm%d, aux%dm, guard%d',...
                       norm_param.sm_len,norm_param.aux_m, ...
                       norm_param.guard_num_bw));
    set(tt,'fontsize',12);
    colorbar

    % Get normalizer output
    norm_param.sm_len = 200;    % smooth length
    norm_param.aux_m = 200;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    plot_normalized_echogram(subplot(325),beamform_norm,meta,norm_caxis,axis_lim);
    tt = title(sprintf('sm%d, aux%dm, guard%d',...
                       norm_param.sm_len,norm_param.aux_m, ...
                       norm_param.guard_num_bw));
    set(tt,'fontsize',12);
    colorbar

    % Get normalizer output
    norm_param.sm_len = 100;    % smooth length
    norm_param.aux_m = 300;        % length of auxiliary band in [m]
    norm_param.guard_num_bw = 2;   % 2/BW
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);
    plot_normalized_echogram(subplot(326),beamform_norm,meta,norm_caxis,axis_lim);
    tt = title(sprintf('sm%d, aux%dm, guard%d',...
                       norm_param.sm_len,norm_param.aux_m, ...
                       norm_param.guard_num_bw));
    set(tt,'fontsize',12);
    colorbar
    
    mtit(title_text,'fontsize',16);
    
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');
end


