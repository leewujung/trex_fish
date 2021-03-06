% 2017 02 26  Echogram with echo pdf side-by-sidefor selected pings in run 131
% 2018 01 14  Re-plot after resizing AW2 to match that of AW1

% Set up various paths
if isunix
    addpath('~/code_matlab_dn/saveSameSize');
    addpath('~/code_git/trex_fish/Triplet_processing_toolbox');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\trex\trex_fish_code\Triplet_processing_toolbox');
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Set params
run_num = 87;
if run_num==87
    ping_num = [100,164,183,197,231,462,766,835,873,936];  % run 087
    ori_caxis = [180 210];  % wfm 1 of run 131
elseif run_num==131
    ping_num = [49,95,103,113,441,455,507,781,795,797,813];  % run 131
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
npt = 50;
win_perc = 0.2;  % proportion of total signal length to form a window for
                 % spectral estimation
axis_lim = [-4.5 -1.5 -4.5 -1.5];
color_axis = [180 210];

% Analysis windows
no_rr = [3.71999,3.92];  % Area not including wreck
no_aa = [-2.45,-2.26];   % modified 2018/01/14 (make sizes of AW2=AW1)
wr_rr = [3.92,4.12];  % USS Strength shipwreck
wr_aa = [-2.40,-2.21];

% Set up figure
fig = figure('position',[280 60 800 500]);
corder = get(gca,'colororder');

% Loop through each ping
for iP=1:length(ping_num)

    % Load file and set filename
    fname = sprintf('%s_ping%04d.mat',data_path,ping_num(iP));
    ping_num_curr = ping_num(iP);
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num_curr);

    disp(['Processing ',fname])
    A = load(fullfile(base_data_path,data_path,fname));
    
    % Range/angle index
    [no_r_idx,no_a_idx] = ...
        get_ra_idx_crd_coh(A.data.range_beam,A.data.polar_angle,...
                           no_rr*1e3,no_aa/pi*180);
    [wr_r_idx,wr_a_idx] = ...
        get_ra_idx_crd_coh(A.data.range_beam,A.data.polar_angle,...
                           wr_rr*1e3,wr_aa/pi*180);
    [no_pie_x,no_pie_y] = get_pie_outline(A.data.polar_angle(no_a_idx),...
                                          A.data.range_beam(no_r_idx));
    [wr_pie_x,wr_pie_y] = get_pie_outline(A.data.polar_angle(wr_a_idx),...
                                          A.data.range_beam(wr_r_idx));

    % Get echo envelope and smoothed envelope
    % Note it's better to do this before cutting out specific piece to avoid
    % matched filter artifact at the beginning and end of the time series
    [mf_env,~] = get_mf_env_xy(A,sm_len);

    % Extract matched filter output
    no = A.data.beam_mf_in_time(no_r_idx(1):no_r_idx(2),...
                                no_a_idx(1):no_a_idx(2));
    wr = A.data.beam_mf_in_time(wr_r_idx(1):wr_r_idx(2),...
                                wr_a_idx(1):wr_a_idx(2));
    no_env = mf_env.env(no_r_idx(1):no_r_idx(2),no_a_idx(1):no_a_idx(2));
    wr_env = mf_env.env(wr_r_idx(1):wr_r_idx(2),wr_a_idx(1):wr_a_idx(2));
    
    % Get echo stat
    no_stat = get_stat(no_env,npt);
    wr_stat = get_stat(wr_env,npt);

    % Get transmission time
    time_hh = A.data.time_hh_local+A.data.time_mm_local/60+A.data.time_ss_local/3600;

    % Rayleigh distribution
    rayl_x = linspace(1e3,1e8,1000);
    rayl_p = raylpdf(rayl_x,sqrt(no_stat.lambda/2));

    %------- PLOT ------------
    title_text = sprintf('Run %d, Ping %d, %02d:%02d:%02d',...
                         run_num,ping_num_curr,A.data.time_hh_local,...
                         A.data.time_mm_local,A.data.time_ss_local);

    % echogram
    subplot(121)
    cla
    h = plot_small_echogram(subplot(121),A,sm_len,color_axis,axis_lim);
    hold on
    hbox1 = plot(no_pie_x/1e3,no_pie_y/1e3,'m','linewidth',2);
    hbox2 = plot(wr_pie_x/1e3,wr_pie_y/1e3,'m','linewidth',2);
    hold off
    colorbar('location','southoutside')
    set(gca,'fontsize',12,'xtick',-4.3:1:-1.3,'ytick',-4.5:1:-1.5);
    axis([-4.3 -1.3 -4.5 -1.5]);
    xlabel('Distance (km)','fontsize',16)
    ylabel('Distance (km)','fontsize',16)
    set(gca,'layer','top')

    subplot(122)  % stat
    cla
    hray = loglog(rayl_x,rayl_p,'color',ones(1,3)*220/255,'linewidth',2);
    hold on
    hno_scat_kde = loglog(no_stat.x_kde,no_stat.px_kde,...
                          'color',corder(2,:),'marker','.','markersize',12,...
                          'linewidth',0.5,'linestyle','-');
    hwr_scat_kde = loglog(wr_stat.x_kde,wr_stat.px_kde,...
                          'color',corder(1,:),'marker','.','markersize',12,...
                          'linewidth',0.5,'linestyle','-');
    ll = legend('Rayleigh','no wreck','wreck');
    set(ll,'fontsize',12,'location','southoutside')
    axis([1e4 5e7 5e-10 3e-6])
    xlabel('Echo magnitude','fontsize',16)
    ylabel('PDF','fontsize',16)
    set(gca,'fontsize',12,'ytick',[1e-9,1e-8,1e-7,1e-6],...
        'xtick',[1e4,1e5,1e6,1e7,1e8])
    hold off
    grid
    set(gca,'layer','top')

    mtit(title_text,'fontsize',16);
    
    epswrite(fullfile(save_path,[save_fname,'.eps']))
    saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');

end




