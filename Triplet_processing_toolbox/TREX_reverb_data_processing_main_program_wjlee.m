% 2016 06 16  Beamform from raw data, linear processing only, not triplet

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the main program to process TREX reverberation data recorded
% on the triplet array FORA.
% It mainly contains four parts:
% Part 1. Set up triplet including # of active channels, gain, processing
%         start and end times, option to filter or compress, option to beamform or not.
% Part 2. Load in the transmission file (Engineering Control File, ECF)
%         which contains signal info for every ping in the current data set.
%         Information will be used to define bandwidth, frequency for automatic
%         processing.
% Part 3. Enter raw data directory and define ping numbers for mass processing.
% Part 4. Main loop to process multiple pings
%       Part 4.1 Read-in triplet data and header info
%       Part 4.2 Perfom filtering only or pulse compression to data. If
%                pulse compression, generate theoretical waveforms.
%       Part 4.3 Beamform filtered or compressed data
%       Part 4.4 Normalization for beam results
%       Part 4.5 Plot 360deg beamed reverb with bathy and clutter objects
%       Part 4.6 Save raw or processed data and figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;






M2     =  [30.0599; -85.6811]; % GPS location of the array

param.map_coord = M2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 1. Set up triplet including data run number, # of active channels, gain, processing
%         Run number is used to find a fixed heading for later processing.
%         start and end times, option to filter or compress, option to beamform or not.

run_num = 87;
TripInUseDtChn = 3;  %  1-triplet, 3-array
TripInUseChn0 = 91;     % start channel NO.
TripInUseChn1 = 234;    % end channel NO.
TripInUseChNum = length([TripInUseChn0:TripInUseDtChn:TripInUseChn1]);

t_start = 0;
t_end  =  20;

addpath('/home/wu-jung/Dropbox/0_CODE_ubuntu/trex_processing/Triplet_processing_toolbox')
Option_Filter_or_Comp = 2;
Option_beamform = 1;

if run_num <= 53     % Fixed heading for different runs
    process_heading = 219;
elseif run_num > 53 & run_num <= 62
    process_heading = 333;
else
    process_heading = 353;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 2. Load in the transmission file (Engineering Control File, ECF)
%         which contains signal info for every ping in the current data set.
%         Information will be used to define bandwidth, frequency for automatic
%         processing.

base_data_path = '~/trex_data/TREX13_Reverberation_Package/TREX_FORA_DATA/';
base_save_path = '~/internal_2tb/trex';
full_data_path = fullfile(base_data_path,sprintf('r%d',run_num));
ecf_file = dir([full_data_path,filesep,'*.ecf']);
[waveform_name,waveform_amp,Nrep,digit_timesec,delay_timems,allsignal_info] = ...
    func_read_ECF(fullfile(full_data_path,ecf_file.name));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 3. Enter raw data directory and define ping numbers for mass processing.

all_datafiles = dir([fullfile(full_data_path, '*.DAT')]);   %% find all .dat files
if size(all_datafiles) ~= size(allsignal_info,1)   %% make sure .dat match transmission
    disp('Total number of pings does not match ECF file. Something is wrong.');
    return;
end

wfm = 1;    % waveform data wanted
n_wfm = 1;  % number of waveforms in this run
n_ping = floor(length(all_datafiles)/n_wfm);  % number of pings per waveform


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 4. Main loop for mass processing

want_file_idx = wfm:n_wfm:length(all_datafiles);  % indices of
                                                  % files wanted

for nsig = want_file_idx(1:20)
    % nsig = 1;

    %%       Part 4.1 Read-in triplet data including acoustic data, heading,
    %        roll, time, and frequency
    %        Heading_T1,Heading_T2 from heading sensor but not used in
    %        processing. Fixed heading is used.

    %    [Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,sample_freq,sample_time_ms, tot_data] = ...
    %        func_load_raw_FORA_data_wjlee(full_data_path, all_datafiles, nwfm);
    [Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,sample_freq,sample_time_ms, tot_data] = ...
        func_load_raw_FORA_data(full_data_path, all_datafiles, nsig, t_start, t_end,...
                                TripInUseChn0,TripInUseDtChn,TripInUseChn1);

    Nt = length(sample_time_ms);
    t = sample_time_ms/1000;

    %%       Part 4.2 Perfom filtering only or pulse compression to data. If
    %       pulse compression, generate theoretical waveforms.

    %   Use info from the ECF file to recontruct, bandwidth, center freq,
    %   pulse length, and tapering. Tau is

    [F1, F2, PL, Taper] = func_extract_signal_info(nsig, allsignal_info);


    center_freq = (F1+F2)/2*1000;
    full_bandwidth = (F2-F1)*1000;
    tau = 1/full_bandwidth;

    if( full_bandwidth == 0 ) %% for cw signals, give 10 Hz bandwidth
        full_bandwidth = 10;
        tau = 1/full_bandwidth;
    end

    % Filter, pulse compress, or do nothing to data

    % generate drive voltage, conjugate FFT for later compression and
    % normalization the drive voltage peak to 1  (To LFM signals, peak
    % is at the edges of pass and stop bands. This induces less than
    % half dB in comparison with normalization using energy.)
    drive_voltage_source = gen_theoretical_waveform(sample_freq, F1, F2, PL, Taper);

    drive_voltage_source_conjfft = conj(fft(drive_voltage_source, size(tot_data,2)));
    drive_voltage_source_conjfft = drive_voltage_source_conjfft/...
        max( abs(drive_voltage_source_conjfft) ); %%% filter function with normalization applied!

    % Pulse compression
    filtered_data = zeros(TripInUseChNum, size(tot_data,2));

    for nch = 1:TripInUseChNum
        select_data = squeeze(tot_data(nch, :));
        filtered_data(nch,:) = ...
            Gaussian_PCM_fil(select_data,t,center_freq,full_bandwidth,drive_voltage_source_conjfft);
    end



    %%       Part 4.3 Beamform raw, filtered or compressed data

    th = -87:87;  % defined from broadside
    dt = t(2)-t(1);  % 1/fs
    cw = 1525;  % sound speed

    param.th = th;
    param.dt = dt;
    param.cw = cw;

    %Get array shape
    % get array shape parameter with Newfora_spv_trip, provided by original author and changed by us for channel selection.
    [Y_a,X_a,Z_a] = Newfora_spv_trip(Roll_T2,Roll_T2,TripInUseChn0,TripInUseChn1,TripInUseDtChn);%% this one looks right based on the left-right discrimination of the result.
    array_coord = [X_a',Y_a',Z_a'];

    param.array_coord = array_coord;    

    % Define a moving Gaussian window, with the size of 1/bandwidth,
    % to take in small chunk of data and beamform. Provide the total
    % number of Gaussian windows given the signal recording time.
    [Gaus_window,Npts,N_win,step_size,t_win] = func_gen_Gaussian_window(tau,t,sample_freq);
    idx_t_win_at_one = find(t_win>1,1,'first');
    r_win = (t_win-1)*cw;  % range adjusted to 1 sec after transmission


    %  Beamforming with moving Gaussian window, stepsize tau = 1/bandwidth
    clear select_data;

    for nwin = 1:N_win
        disp(['nwin=',num2str(nwin)])

        for nch = 1:TripInUseChNum
            select_data(nch,:) = reshape( filtered_data(nch,(nwin-1)*step_size+[1:Npts]),...
                                          1,Npts ).*Gaus_window; % Gaussian window
        end
        f0 = max(center_freq-full_bandwidth/2,1);
        f1 = min(center_freq+full_bandwidth/2,1/dt*0.5);
        tmp = linear_beamformer(select_data,X_a,Y_a,Z_a,th, ...
                                dt,cw,f0,f1);
        beamform(nwin,:) = sum(abs(tmp).^2,2);

    end

    %%       Part 4.4 Normalization and 3.18 deg magnetic correction
    angle_of_array = process_heading+3.18;

    % Data for plotting starts at 1 sec after transmission
    r_win_adj = r_win(idx_t_win_at_one:end);
    beamform_adj = beamform(idx_t_win_at_one:end,:);


    %%       Part 4.5 Plot 360deg beamed reverb with bathy and clutter objects,
    polar_angle = angle_of_array+th;
    [aa,rr] = meshgrid(polar_angle/180*pi,r_win_adj/1000/2);
    [X,Y] = pol2cart(aa,rr);

    % load in bathymetry map and clutter objects
    [Map_X,Map_Y,Map_Z,wrecgps] = func_load_map_targets(M2);

    % plot data for this ping
    figure;
    h1 = pcolor(X,Y,10*log10(beamform_adj));  % plot echoes
    set(h1,'edgecolor','none')
    hold on
    [c,h2]=contour(Map_X/1000,Map_Y/1000,Map_Z,[0:-2:-30],'k');  % plot map contour
    clabel(c,h2,'fontsize',8,'linewidth',1,'Color','k');
    axis equal
    colormap(jet)
    colorbar
    caxis([60 100])

    % save data
    result.t_win = t_win;
    result.r_win = r_win;
    result.beamform = beamform;
    result.idx_t_win_at_one = idx_t_win_at_one;

    result.r_win_adj = r_win_adj;
    result.beamform_adj = beamform_adj;
    result.theta = th;
    result.angle_of_array = angle_of_array;
    result.X = X;
    result.Y = Y;

    result.filtered_data = filtered_data;
    result.center_freq = center_freq;
    result.twosided_bandwidth = full_bandwidth;
    result.F1 = F1;
    result.F2 = F2;
    result.PL = PL;
    result.Taper = Taper;
    result.sample_freq = sample_freq;
    result.tau = tau;
    
    save( [resultpathname,'\',outpt_name],'result','pathname','data_filename');
    figure(30);
    saveas( gcf,[resultpathname,'\',outpt_name], 'tif');


end