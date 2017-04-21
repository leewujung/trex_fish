% 2017 02 26  Revised from plot_normalizer_split_window_output()
% 2017 02 27  Revised to use plot_normalized_echogram()

% Set up various paths
if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/epsutil');
    addpath('~/internal_2tb/trex/trex_fish_code/Triplet_processing_toolbox');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\MATLAB\epsutil');
    addpath('F:\trex\trex_fish_code\Triplet_processing_toolbox');
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Set params
run_num = 131;
if run_num==87
    ping_num = [100,164,183,197,231,462,766,835,873,936,...
                134,167,201,857];  % run 087
    ori_caxis = [180 210];  % wfm 1 of run 131
elseif run_num==131
    ping_num = [23,507,781];
%     ping_num = [13,103,113,261,441,507,651,781,797,813,893];  % run 131
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
sm_len = 100;
axis_lim = [-4.3 -1.3 -4.5 -1.5];
norm_caxis = [5 15];
norm_param.sm_len = sm_len;    % smooth length
norm_param.aux_m = 200;        % length of auxiliary band in [m]
norm_param.guard_num_bw = 2;   % 2/BW
norm_detail_plot = 0;


% Set up figure
fig = figure('position',[280 60 800 560]);
corder = get(gca,'colororder');

% Loop through each ping
for iP=1:length(ping_num)
   
    fname = sprintf('%s_ping%04d.mat', data_path,ping_num(iP));
    ping_num_curr = ping_num(iP);
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num_curr);

    disp(['Processing ',fname])
    A = load(fullfile(base_data_path,data_path,fname));
    
    title_text = sprintf('Run %d, Ping %d, %02d:%02d:%02d',...
                         run_num,ping_num_curr,A.data.time_hh_local,...
                         A.data.time_mm_local,A.data.time_ss_local);

    % Get normalizer output
    [beamform_norm,meta,fig_norm] = normalizer_split_window(A,norm_param,norm_detail_plot);
    if norm_detail_plot
        suptitle(title_text);
        saveas(fig_norm,fullfile(save_path,[save_fname,'_smcmp.fig']))
        saveSameSize_300(gcf,'file',fullfile(save_path,[save_fname,'_smcmp.png']),...
            'format','png');
    end

    
    % Plotting
    figure(fig)
    suptitle(title_text)
    
    h_ori = plot_small_echogram(subplot(121),A,sm_len,ori_caxis,axis_lim);
    colorbar('location','southoutside')
    set(gca,'fontsize',12,'xtick',-4.3:1:-1.3,'ytick',-4.5:1:-1.5);
    axis([-4.3 -1.3 -4.5 -1.5]);
    xlabel('Distance (km)','fontsize',16)
    ylabel('Distance (km)','fontsize',16)
    set(gca,'layer','top')

    % Get normalizer output
    plot_normalized_echogram(subplot(122),beamform_norm,meta,norm_param,norm_caxis,axis_lim);
    tt = title(sprintf('sm%d, aux%dm, guard%d',...
                       norm_param.sm_len,norm_param.aux_m, ...
                       norm_param.guard_num_bw));
    set(tt,'fontsize',12);
    colorbar('location','southoutside')
    set(gca,'fontsize',12,'xtick',-4.3:1:-1.3,'ytick',-4.5:1:-1.5);
    axis([-4.3 -1.3 -4.5 -1.5]);
    xlabel('Distance (km)','fontsize',16)
    ylabel('Distance (km)','fontsize',16)
    set(gca,'layer','top')
    
    epswrite(fullfile(save_path,[save_fname,'.eps']))
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');
    
    % bw version
    colormap(brewermap([],'Greys'))
    epswrite(fullfile(save_path,[save_fname,'_bw.eps']))
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'_bw.png']),...
        'format','png');

end


