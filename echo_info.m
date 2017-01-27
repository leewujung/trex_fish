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

clear

if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath(['~/internal_2tb/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])
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
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Set view area
axis_xy = [-5 -1 -5 -1];

% Area not including wreck
no_rr = [3.60,3.92];
no_aa = [-2.45,-2.27];

% Wreck only
wr_rr = [3.92,4.12];  % USS Strength
wr_aa = [-2.38,-2.21];
%wr_rr = [4.16,4.38];  % Bridge span
%wr_aa = [-2.53,-2.36];

% Ping range
ping_all = 1:2;
plot_opt = 1;

% Params for plotting
cmap = 'jet';
sm_len = 100;
npt = 50;
win_perc = 0.2;  % proportion of total signal length to form a window for
                 % spectral estimation

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
    [mf_env,plot_param] = get_mf_env_xy(A,sm_len);

    % Extract matched filter output
    no = A.data.beam_mf_in_time(no_r_idx(1):no_r_idx(2),...
                                no_a_idx(1):no_a_idx(2));
    wr = A.data.beam_mf_in_time(wr_r_idx(1):wr_r_idx(2),...
                                wr_a_idx(1):wr_a_idx(2));
    no_env = mf_env.env(no_r_idx(1):no_r_idx(2),...
                        no_a_idx(1):no_a_idx(2));
    wr_env = mf_env.env(wr_r_idx(1):wr_r_idx(2),...
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
    
    % Store extracted info
    S.spec_no = no_spec;
    S.spec_wr = wr_spec;
    S.env_no = no_env;
    S.env_wr = wr_env;
    S.stat_no = no_stat;
    S.stat_wr = wr_stat;
   
    % Save file
    save(fullfile(save_path,[save_fname,'_info.mat']),'-struct','S');
    
    
    %------- PLOT ------------
    if plot_opt
    title_text = sprintf('Run %d, Ping %d, %s',run_num,ping_num,A.time_str_scat);
    
    subplot(131)  % echogram
    cla
    h1 = pcolor(plot_param.X_sm/1e3,plot_param.Y_sm/1e3,...
                20*log10(mf_env.env_sm)+A.param.gain_load-A.param.gain_sys-...
                A.param.gain_beamform-A.param.gain_pc);
    set(h1,'edgecolor','none');
    hold on
    plot(no_pie_x/1e3,no_pie_y/1e3,'r','linewidth',2);
    plot(wr_pie_x/1e3,wr_pie_y/1e3,'r','linewidth',2);
    axis equal
    axis([-4.5 -1.5 -4.5 -1.5])
    title(sprintf('Run %d, Ping %d, %s',run_num,ping_num,A.time_str_scat));
    caxis([80 110])
    colormap(cmap);
    xlabel('Distance (km)'); ylabel('Distance (km)');
    colorbar('location','southoutside')
    
    subplot(132)  % stat
    cla
    hr = loglog(x_rayl,rayl,'k');
    hold on
    hno_scat_kde = loglog(no_stat.x_kde,no_stat.px_kde,'color',corder(1,:),'linewidth',2);
    hwr_scat_kde = loglog(wr_stat.x_kde,wr_stat.px_kde,'color',[153,204,255]/255,'linewidth',2);
    ll = legend('no wreck','wreck');
    set(ll,'fontsize',11,'location','southoutside')
    axis([5e3 1e8 1e-10 3e-6])
    xlabel('Echo magnitude')
    ylabel('PDF')
    hold off
    grid
    
    subplot(133)  % spectrum
    cla
    plot(no_spec.freq_vec,no_spec.pxx_dB_mean_comp,...
        'color',corder(1,:),'linewidth',2);
    hold on
    plot(wr_spec.freq_vec,wr_spec.pxx_dB_mean_comp,...
        'linewidth',2,'color',[153,204,255]/255);
    ll = legend('no wreck','wreck');
    set(ll,'fontsize',11,'location','southoutside')
    ylim([-140 -100])
    xlim([1.5e3 3.8e3])
    xlabel('Frequency (Hz)')
    ylabel('Spectral density (dB/Hz)') 
    grid on
    box on
    
    saveSameSize_100(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');
    end
end



