% 2017 02 26  Revised from plot_normalizer_split_window_output()


addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
addpath(['~/internal_2tb/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])

% Set up various paths
base_data_path='~/internal_2tb/trex/figs_results/';
base_save_path='~/internal_2tb/trex/figs_results/';
data_path='subset_beamform_cardioid_coherent_run087';

% Run and ping number
%ping_num = [13,103,113,261,441,507,651,781,797,813,893]+1;
ping_num = 1:1000;
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
norm_caxis = [10 15];
norm_param.sm_len = sm_len;    % smooth length
norm_param.aux_m = 200;        % length of auxiliary band in [m]
norm_param.guard_num_bw = 2;   % 2/BW


% Set up figure
fig = figure('position',[280 60 1000 500]);
corder = get(gca,'colororder');

% Loop through each ping
for iP=1:length(ping_num)

    fname = sprintf('%s_ping%04d.mat', data_path,ping_num(iP));
    ping_num_curr = ping_num(iP);
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num_curr);

    disp(['Processing ',fname])
    A = load(fullfile(base_data_path,data_path,fname));
    
    % Get normalizer output
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);

    % Plotting
    title_text = sprintf('Run %d, Ping %d, %02d:%02d:%02d',...
                         run_num,ping_num_curr,A.data.time_hh_local,...
                         A.data.time_mm_local,A.data.time_ss_local);
    figure(fig)
    h_ori = plot_small_echogram(subplot(121),A,sm_len,ori_caxis,axis_lim);

    subplot(122)
    cla
    h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
    hold on
    set(h_norm,'edgecolor','none');
    axis equal
    colormap(jet)
    colorbar('location','southoutside');
    caxis(norm_caxis)
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    
    mtit(title_text,'fontsize',16);
    
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');
end


