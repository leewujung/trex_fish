% 2016 08 30  Echo stat of background and fish school
% 2016 09 16  Revise to plot only smoothed and subsampled envelope
%             Get both statistics and intensity information
% 2016 09 19  Revise to compare RAW (un-normalized) pdf
% 2016 09 19  Spectral variation near wreck
% 2016 09 19  Use data subset
% 2016 11 21  Revised from 'echo_int_coh_wreck.m'
%             use SL to calibrate the spectrum
%             save info extracted for each ping
% 2017 01 25  Clean up code to work with new beamforming results
% 2018 01 13  Make AW2 (empty space) the same size as AW1 (wreck)


clear

if isunix
    addpath('~/code_matlab_dn/saveSameSize');
    addpath(['~/code_git/trex_fish/Triplet_processing_toolbox'])
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\trex_fish\Triplet_processing_toolbox')
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Set up various paths
data_path = 'subset_beamform_cardioid_coherent_run131';
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d_new',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Ping range
ping_all = 1:1000;
plot_opt = 1;

% Set params
cmap = 'jet';
sm_len = 100;
npt = 50;
win_perc = 0.2;  % proportion of total signal length to form a window for
                 % spectral estimation
axis_lim = [-5 -1 -5 -1];
color_axis = [180 210];

% Area not including wreck
no_rr = [3.71999,3.92];  % modified 2018/01/13 (make sizes of AW2=AW1)
no_aa = [-2.45,-2.26];

% Wreck only
wr_rr = [3.92,4.12];  % USS Strength
wr_aa = [-2.40,-2.21];
%wr_rr = [4.16,4.38];  % Bridge span
%wr_aa = [-2.53,-2.36];

% Load boundary
BND = load(fullfile(base_data_path,'bnd.mat'));

% Rayleigh distr
x_rayl = logspace(-3,log10(2000),500);  % standard
rayl = raylpdf(x_rayl,1/sqrt(2));

fig = figure('position',[280 60 1500 500]);
corder = get(gca,'colororder');
for iP=1:length(ping_all)

    % Load file and set filename
    ping_num = ping_all(iP);
    scat_fname = sprintf('%s_ping%04d.mat',data_path,ping_num);
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num);
    disp(['Processing ',scat_fname])
    A = load(fullfile(base_data_path,data_path,scat_fname));
    
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
    
    % Get SL for spectral calibration
    if mod(ping_num,2)  % odd number
        SL = get_SL(run_num,1);  
    else
        SL = get_SL(run_num,2);
    end

    % Get raw echo spectrum (without any compensation)
    no_spec = get_spectrum_mtm(no,A.data.sample_freq,win_perc);
    wr_spec = get_spectrum_mtm(wr,A.data.sample_freq,win_perc);

    % Compensation for all factors 
    no_spec = compensate_echo_spectrum(no_spec,SL,A);
    wr_spec = compensate_echo_spectrum(wr_spec,SL,A);

    % Get echo stat
    no_env = mf_env.env(no_r_idx(1):no_r_idx(2),no_a_idx(1):no_a_idx(2));
    wr_env = mf_env.env(wr_r_idx(1):wr_r_idx(2),wr_a_idx(1):wr_a_idx(2));
    
    no_stat = get_stat(no_env,npt);
    wr_stat = get_stat(wr_env,npt);

    no_bf_env_max = max(no_env(:));
    wr_bf_env_max = max(wr_env(:));
    
    % Get index within irregular boundary BND
    [amesh_fine,rmesh_fine] = ...
        meshgrid(A.data.polar_angle/180*pi,A.data.range_beam);
    [X_fine,Y_fine] = pol2cart(amesh_fine,rmesh_fine);
    X_fine_col = X_fine(:);
    Y_fine_col = Y_fine(:);
    idx_in_bnd = inpolygon(X_fine/1e3,Y_fine/1e3,BND.xg,BND.yg);
    %    idx_in_bnd = inpolygon(X_fine_col/1e3,Y_fine_col/1e3,BND.xg,BND.yg);
    energy_in_bnd = sum(A.data.beam_mf_in_time(idx_in_bnd).^2);

    % Store extracted info
    S.no = no;
    S.wr = wr;
    S.spec_no = no_spec;
    S.spec_wr = wr_spec;
    S.env_no = no_env;
    S.env_wr = wr_env;
    S.stat_no = no_stat;
    S.stat_wr = wr_stat;
    S.energy_in_bnd = energy_in_bnd;

    % Save file
    save(fullfile(save_path,[save_fname,'.mat']),'-struct','S');
    
    %------- PLOT ------------
    if plot_opt
    title_text = sprintf('Run %d, Ping %d, %02d:%02d:%02d',...
                         run_num,ping_num,A.data.time_hh_local,...
                         A.data.time_mm_local,A.data.time_ss_local);

    % echogram
    h = plot_small_echogram(subplot(131),A,sm_len,color_axis,axis_lim);
    hold on
    plot(no_pie_x/1e3,no_pie_y/1e3,'m','linewidth',2);
    plot(wr_pie_x/1e3,wr_pie_y/1e3,'m','linewidth',2);
    plot(BND.xg,BND.yg,'m','linewidth',2)
    hold off

    subplot(132)  % stat
    cla
    hno_scat_kde = loglog(no_stat.x_kde,no_stat.px_kde,...
                          'color',corder(1,:),'linewidth',2);
    hold on
    hwr_scat_kde = loglog(wr_stat.x_kde,wr_stat.px_kde,...
                          'color',[153,204,255]/255,'linewidth',2);
    ll = legend('no wreck','wreck');
    set(ll,'fontsize',11,'location','southoutside')
    axis([5e3 5e8 1e-10 3e-6])
    xlabel('Echo magnitude','fontsize',14)
    ylabel('PDF','fontsize',14)
    set(gca,'fontsize',12,'xtick',[1e4,1e6,1e8])
    hold off
    grid
    
    subplot(133)  % spectrum
    cla
    plot(no_spec.freq_vec/1e3,no_spec.pxx_dB_mean_comp,...
        'color',corder(1,:),'linewidth',2);
    hold on
    plot(wr_spec.freq_vec/1e3,wr_spec.pxx_dB_mean_comp,...
        'linewidth',2,'color',[153,204,255]/255);
    ll = legend('no wreck','wreck');
    set(ll,'fontsize',11,'location','southoutside')
    ylim([-140 -100])
    xlim([1.6 3.8])
    xlabel('Frequency (kHz)','fontsize',14)
    ylabel('Spectral density (dB/Hz)','fontsize',14)
    set(gca,'fontsize',12,'xtick',1.6:0.4:3.8,'ytick',-140:10:-100)
    grid on
    box on

    mtit(title_text,'fontsize',16);
    
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');
    end
end



