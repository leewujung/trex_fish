% 2017 01 13  Modify from beamform_cardioid_coherent to compare
%             **coherent** linear and cardioid processing

clear
if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath(['~/internal_2tb/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/trex_data/TREX13_Reverberation_Package/TREX_FORA_DATA/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\trex_fish\Triplet_processing_toolbox')
    base_save_path = 'F:\trex\figs_results';
    base_data_path = '\\10.95.97.212\Data\TREX13_Reverberation_Package\TREX_FORA_DATA/';
end


%% Setting param and paths to read file
video_opt = 0;   % 1-save video, 0-no video
plot_opt = 0;

run_num = 131;
wfm = 3;    % waveform wanted
n_wfm = 9;  % number of waveforms in this run

TripInUseDtChn = 1;  %  1-triplet, 3-array
TripInUseChn0 = 91;     % start channel NO.
TripInUseChn1 = 234;    % end channel NO.
TripInUseChNum = length([TripInUseChn0:TripInUseDtChn:TripInUseChn1]);

t_start = 0;   % start time within ping
t_end  =  20;  % end time within ping

% beamform_angle = -87:87;  % defined from broadside--for linear bf
% beamform_angle = [-177:-3 3:177];   % defined from endfire angle--for cardioid bf
beamform_angle = [0:5:180];
% beamform_angle = 3:177;
cw = 1525;  % sound speed

rr_wanted = [];  % range to be processed, [] for all data [m]

M2 = [30.0599; -85.6811]; % GPS location of the array

param.run_num = run_num;
param.wfm = wfm;
param.n_wfm = n_wfm;
param.TripInUseDtChn = TripInUseDtChn;
param.TripInUseChn0 = TripInUseChn0;
param.TripInUseChn1 = TripInUseChn1;
param.TripInUseChNum = TripInUseChNum;
param.t_start = t_start;
param.t_end = t_end;
param.cw = cw;
param.raw_range_processed = rr_wanted;
param.map_coord = M2;

% Get processing heading
if run_num <= 53     % Fixed heading for different runs
    process_heading = 219;
elseif run_num > 53 && run_num <= 62
    process_heading = 333;
else
    process_heading = 353;
end

param.process_heading = process_heading;

% Set save folder
[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path, ...
    sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end


%% Set data path and read ECF
full_data_path = fullfile(base_data_path,sprintf('r%d',run_num));
ecf_file = dir([full_data_path,filesep,'*.ecf']);
[waveform_name,waveform_amp,Nrep,digit_timesec,delay_timems,allsignal_info] = ...
    func_read_ECF(fullfile(full_data_path,ecf_file(1).name));

all_datafiles = dir([fullfile(full_data_path, '*.DAT')]);   %% find all .dat files
if size(all_datafiles) ~= size(allsignal_info,1)   %% make sure .dat match transmission
    disp('Total number of pings does not match ECF file. Something is wrong.');
    return;
end

param.full_data_path = full_data_path;


%% Set params for reading raw files
n_ping = floor(length(all_datafiles)/n_wfm);  % number of pings per waveform

param.n_ping = n_ping;


%% Data processing loop
% Prepare video file
if video_opt
    vobj = VideoWriter(fullfile(save_path,...
        sprintf('run%d_wfm%d_allFrame.avi',run_num,wfm)));
    vobj.FrameRate = 5;
    open(vobj);
end

if plot_opt
    fig_polar = figure('position',[150,80,900,700]);
end


want_file_idx = 150;

param.want_file_idx = want_file_idx;

for nsig = want_file_idx
    
    % Get data filename and time
    fname = strtok(all_datafiles(nsig).name,'.');
    date_str = fname(end-9:end-7);
    time_str = fname(end-5:end);
    time_hh_local = mod(str2double(time_str(1:2))-5,24);
    time_mm_local = str2double(time_str(3:4));
    time_ss_local = str2double(time_str(5:6));
    
    data.file_name = fname;
    data.file_date = date_str; % julian day
    data.file_time = time_str; % [HHMMSS]
    data.time_hh_local = time_hh_local;
    data.time_mm_local = time_mm_local;
    data.time_ss_local = time_ss_local;
    
    % Load data
    % Read-in triplet data including acoustic data, heading, roll, time, and frequency
    % Heading_T1,Heading_T2 from heading sensor but not used in processing.
    % Fixed heading is used.
    [Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,sample_freq,sample_time_ms,tot_data] = ...
        func_load_raw_FORA_data(full_data_path, all_datafiles, nsig, t_start, t_end,...
        TripInUseChn0,TripInUseDtChn,TripInUseChn1);
    Nt = length(sample_time_ms);
    t = sample_time_ms/1000;  % time stamp of each sample [sec]
    %rr = t*cw/2;  % rough range estimate [m]
    
    data.Roll_T1 = Roll_T1;
    data.Roll_T2 = Roll_T2;
    data.Heading_T1 = Heading_T1;
    data.Heading_T2 = Heading_T2;
    data.GLAT = GLAT;
    data.GLON = GLON;
    data.sample_freq = sample_freq;
    data.t = t;
    %     data.tot_data = tot_data;
    %     data.rr = rr;
    
    % Use info from the ECF file to recontruct, bandwidth, center freq,
    % pulse length, and tapering.
    [F1, F2, PL, Taper] = func_extract_signal_info(nsig, allsignal_info);
    
    center_freq = (F1+F2)/2*1000;
    full_bandwidth = (F2-F1)*1000;
    tau = 1/full_bandwidth;
    
    tx_sig.F1 = F1;
    tx_sig.F2 = F2;
    tx_sig.PL = PL;
    tx_sig.Taper = Taper;
    tx_sig.center_freq = center_freq;
    tx_sig.full_bandwidth = full_bandwidth;
    tx_sig.tau = tau;
    
    % Get pulse compression template
    % generate drive voltage, conjugate FFT for later compression and
    % normalization the drive voltage peak to 1  (To LFM signals, peak
    % is at the edges of pass and stop bands. This induces less than
    % half dB in comparison with normalization using energy.)
    drive_voltage_source = gen_theoretical_waveform(sample_freq, F1, F2, PL, Taper);
    
    tx_sig.drive_voltage_source = drive_voltage_source;
    
    % Get array geometry
    [y_a,x_a,z_a] = Newfora_spv_trip(Roll_T2,Roll_T2,...
        TripInUseChn0,TripInUseChn1,TripInUseDtChn);
    array_coord = [x_a',y_a',z_a'];
    del_y = y_a-mean(y_a);
    
    param.array_coord = array_coord;
    
    seg = tot_data.';
    
    % fft
    seg_fft = fft(seg);
    seg_len = size(seg,1);
    seg_len_half = floor((seg_len+1)/2);
    dt = t(2)-t(1);  % 1/fs
    df = 1/(seg_len*dt);
    freq_seg = [0:seg_len_half-1]*df;
    seg_fft = seg_fft(1:seg_len_half,:);
    
    % Distance stuff for cardioid beamforming
    x_a_mean = mean(reshape(x_a,3,[]),1)';
    y_a_mean = mean(reshape(y_a,3,[]),1)';
    z_a_mean = mean(reshape(z_a,3,[]),1)';
    dx = reshape(reshape(x_a,3,[])-repmat(x_a_mean',3,1),1,[]);
    dy = reshape(reshape(y_a,3,[])-repmat(y_a_mean',3,1),1,[]);
    dz = reshape(reshape(z_a,3,[])-repmat(z_a_mean',3,1),1,[]);
    r = mean(sqrt(dx.^2+dy.^2+dz.^2));
    
    % CARDIOID PROCESSING =========================
    % Beamforming [cardioid]
    phi = 90/180*pi;  % vertical beamform angle [rad]
    k_seg = 2*pi*freq_seg/cw;
    seg_fft_beam = nan(seg_len_half,length(beamform_angle));
    for iB=1:length(beamform_angle)
%         disp(['angle=',num2str(beamform_angle(iB))])
        u = [sin(phi)*sin(beamform_angle(iB)/180*pi);...
             sin(phi)*cos(beamform_angle(iB)/180*pi);...
             cos(phi)];
        u_vjk_phase = [x_a',y_a',z_a']*u;
        u_vjk_amp = [dx',dy',dz']*u;
        phase_delay = exp(-1j*k_seg.'*u_vjk_phase.');
        amp = repmat(u_vjk_amp.',size(seg_fft,1),1);
        calib_fac = 6*pi*freq_seg * (r*sin(beamform_angle(iB)/180*pi)).^2 /cw;
        calib_fac = repmat(calib_fac.',1,size(seg_fft,2));
        seg_fft_beam(:,iB) = sum(seg_fft.*phase_delay.*amp./calib_fac,2);
        nanidx = isnan(seg_fft_beam(:,iB));
        seg_fft_beam(nanidx,iB) = 0;
    end
    seg_fft_beam_pad = [seg_fft_beam;...
        flipud(conj(seg_fft_beam(2:end,:)))];
    beam_in_time = ifft(seg_fft_beam_pad);
    
    % Pulse compression
    tmp = conj(fft(drive_voltage_source, seg_len));
    tmp = tmp(1:seg_len_half);
    seg_fft_beam_mf = seg_fft_beam.*repmat(tmp.',1,size(seg_fft_beam,2));
    seg_fft_beam_mf_pad = [seg_fft_beam_mf;...
        flipud(conj(seg_fft_beam_mf(2:end,:)))];
    beam_mf_in_time = ifft(seg_fft_beam_mf_pad);
    mf_len = size(beam_mf_in_time,1);

    data.beam_mf_in_time = beam_mf_in_time;

    % LINEAR PROCESSING ===================
    % Beamforming
    seg_fft_beam_lin = nan(seg_len_half,length(beamform_angle));
    for iB=1:length(beamform_angle)
        phase_delay_lin =...  % note angle convention change for linear beamforming
            exp(1j*k_seg'*del_y(1:3:end)*sin((beamform_angle(iB)-90)/180*pi));
        seg_fft_beam_lin(:,iB) = sum(seg_fft(:,1:3:end).*phase_delay_lin,2);
    end
    seg_fft_beam_lin_pad = [seg_fft_beam_lin;...
        flipud(conj(seg_fft_beam_lin(2:end,:)))];
    beam_in_time_lin = ifft(seg_fft_beam_lin_pad);

    % Pulse compression
    tmp = conj(fft(drive_voltage_source, seg_len));
    tmp = tmp(1:seg_len_half);
    seg_fft_beam_lin_mf = seg_fft_beam_lin.*repmat(tmp.',1,size(seg_fft_beam,2));
    seg_fft_beam_lin_mf_pad = [seg_fft_beam_lin_mf;...
        flipud(conj(seg_fft_beam_lin_mf(2:end,:)))];
    beam_mf_in_time_lin = ifft(seg_fft_beam_lin_mf_pad);

    data.beam_mf_in_time_lin = beam_mf_in_time_lin;

    % PLOT ===============================
    % Plot to compare linear and cardioid beamforming
    fig_cmp = figure
    plot(smooth(20*log10(abs(beam_mf_in_time)),1000));
    hold on
    plot(smooth(20*log10(abs(beam_mf_in_time_lin)),1000)-3);
    set(gca,'xtick',length(beam_mf_in_time)*[0:length(beamform_angle)-1],...
            'xticklabel',num2str(beamform_angle))
    ylim([100 200])
    xlabel('Echo time series at different beamform angles');
    ylabel('Un-calibrated raw output value')
    saveas(fig_cmp,fullfile(save_path,[script_name,'.fig']),'fig');
    saveSameSize_150(fig_cmp,'file',fullfile(save_path,[script_name,'.png']),...
                     'format','png');
    close(fig_cmp)

continue;

    % NOTHING BELOW GETS EVALUATED ================
    % Adjust range to transmission start
    [~,m_idx] = max(mean(beam_mf_in_time,2));
    t_max = t(m_idx);
    if t_max>1.5
        cut_idx = find(t>2,1,'first');
        rr_data = (t(1:mf_len)-2)*cw/2;
    else
        cut_idx = find(t>1,1,'first');
        rr_data = (t(1:mf_len)-1)*cw/2;
    end
    data.cut_idx = cut_idx;
    data.range_beam = rr_data;
    
    % Get angle for plotting
    polar_angle = -process_heading-beamform_angle+90;
    [amesh,rmesh] = meshgrid(polar_angle/180*pi,rr_data(cut_idx:end)/1000);
    [X,Y] = pol2cart(amesh,rmesh);
    
    data.polar_angle = polar_angle;
%     data.X = X;
%     data.Y = Y;
    
    % Save results
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,nsig);  % data
    save(fullfile(save_path,[save_fname,'.mat']),'param','tx_sig','data');  % figure

    % Plotting
    if plot_opt
        % Get envelope
        bf_env = nan(size(beam_mf_in_time));
        for iA=1:size(beam_mf_in_time,2)
            bf_env(:,iA) = abs(hilbert(beam_mf_in_time(:,iA)));
        end
        bf_env_cut = 20*log10(bf_env(cut_idx:end,:));
        
        % load in bathymetry map and clutter objects
        [Map_X,Map_Y,Map_Z,wrecgps] = func_load_map_targets(M2);
        
        % Polar energy plot for this ping
        figure(fig_polar)
        cla
        h1 = pcolor(X,Y,bf_env_cut);  % plot echoes
        set(h1,'edgecolor','none')
        hold on
        [c,h2]=contour(Map_X/1000,Map_Y/1000,Map_Z,[0:-2:-30],'k');  % plot map contour
        clabel(c,h2,'fontsize',8,'linewidth',1,'Color','k');
        colormap(jet)
        colorbar
        caxis([130 170])
        axis equal
        xlabel('Distance (km)');
        ylabel('Distance (km)');
        axis([-11 11 -11 11])
        title(sprintf('Ping %04d, local time %02d:%02d:%02d',...
            nsig,time_hh_local,time_mm_local,time_ss_local));
        hold off
        
        % Save plot
        saveSameSize_100(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
            'format','png');
        
        % grab frame for video
        if video_opt
            writeVideo(vobj,getframe(fig_polar));
        end

    end
    
end  % loop through all pings

if plot_opt && video_opt
    close(vobj)
end