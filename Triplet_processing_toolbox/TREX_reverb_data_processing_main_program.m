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

clear; %close all;
clc;

M2     =  [30.0599; -85.6811]; % GPS location of the array
resultpathname =fullfile(pwd ,'result');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(pwd,'result');

display('Make sure array GPS location is correct'); M2
display('Default directory to save processed data is current directory\result')
display('Enter any key to continue')
pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 1. Set up triplet including data run number, # of active channels, gain, processing
%         Run number is used to find a fixed heading for later processing.
%         start and end times, option to filter or compress, option to beamform or not.


TripInUseDtChn = 1;  %  1 for triplet 3 for line array, we must set 1 when use Cardioid_beamformer_foraTrip_INFreq_Domain which has better performance for left-right discrimination
TripInUseChn0 = 91;     % start channel NO.
TripInUseChn1 = 234;    % end channel NO.
TripInUseChNum = length([TripInUseChn0:TripInUseDtChn:TripInUseChn1]);

RunNum = input('Enter Run number:  ');  %%%% Enter run number for data that will be processed
GainSet = input('Enter Gain (dB):');  %%%% Enter gain

t_start = input('Enter processing start time (s):');  %%%% Enter processing time window
t_end  =  input('Enter processing end time (s):');  %%%% Enter processing time window

Option_Filter_or_Comp = input('Enter 0 for raw data; 1 for filtering only; and 2 for pulse compressed data:   ')
Option_beamform = input('Enter 0 for No beamform and 1 for Beamform:   ')

if RunNum <= 53     %% Use run number to automatically find heading for later processing. Fixed heading is used since array is fixed.
    process_heading = 219;
elseif RunNum > 53 & RunNum <= 62
    process_heading = 333;
else
    process_heading = 353;
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 2. Load in the transmission file (Engineering Control File, ECF)
%         which contains signal info for every ping in the current data set.
%         Information will be used to define bandwidth, frequency for automatic
%         processing.

[data_filename, pathname] = uigetfile(fullfile(pwd,'*.ecf'),'FORA ECF File Readin')
full_pathname = sprintf('%s%s', pathname, data_filename)

[waveform_name waveform_amp Nrep digit_timesec delay_timems allsignal_info] = func_read_ECF(full_pathname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 3. Enter raw data directory and define ping numbers for mass processing.

all_datafiles = dir([fullfile(pathname, '*.dat')]);   %% find all .dat files
if size(all_datafiles) ~= size(allsignal_info,1)   %% make sure .dat match transmission
    disp('Total number of pings does not match ECF file. Something is wrong.');
    return;
end

Nsig = length(all_datafiles);  %% total # of signals in this data set

allprocess_ping = [];
for nsig = 1:5	  %% define ping numbers in the data set to process
    %if mod(nf,8) >= 6 | mod(nf,8) == 0 %% For 8wav sequence, wav 6-8 are
    %cw, therefore, no need to pulse compress, can process separately
    %if mod(nf,8) >= 1 & mod(nf,8) <= 5 %% For 8wav sequence, wav 1-5 are
    %wideband, need to pulse compress, can process separately
    allprocess_ping = [allprocess_ping nsig];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 4. Main loop for mass processing

for nsig = allprocess_ping
    
    %%       Part 4.1 Read-in triplet data including acoustic data, heading,
    %        roll, time, and frequency
    %        Heading_T1,Heading_T2 from heading sensor but not used in
    %        processing. Fixed heading is used.
    
    [Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,sample_freq,sample_time_ms, tot_data] = ...
        func_load_raw_FORA_data(pathname, all_datafiles, nsig, t_start, t_end, TripInUseChn0,TripInUseDtChn,TripInUseChn1);
    
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
    if Option_Filter_or_Comp == 0 %% do nothing to data, no filtering, no pulse compression
        filtered_data = tot_data; %% if choose to do nothing to data, raw data will be used
        
    elseif Option_Filter_or_Comp == 1 %% Filter only
        filtered_data = zeros(TripInUseChNum, size(tot_data,2));
        
        for nch = 1 : TripInUseChNum
            select_data = squeeze( tot_data(nch, :) );
            filtered_data( nch, :) = Gaussian_fil( select_data, t, center_freq, full_bandwidth);
        end
        
    elseif Option_Filter_or_Comp == 2 %% Pulse compression
        
        % generate drive voltage, conjugate FFT for later compression and
        % normalization the drive voltage peak to 1  (To LFM signals, peak
        % is at the edges of pass and stop bands. This induces less than
        % half dB in comparison with normalization using energy.)
        drive_voltage_source = gen_theoretical_waveform(sample_freq, F1, F2, PL, Taper);
        
        drive_voltage_source_conjfft = conj(fft(drive_voltage_source, size(tot_data,2)));
        drive_voltage_source_conjfft = drive_voltage_source_conjfft/max( abs(drive_voltage_source_conjfft) ); %%% filter function with normalization applied!
        
        % Pulse compression
        filtered_data = zeros(TripInUseChNum, size(tot_data,2));
        
        for nch = 1 : TripInUseChNum
            
            select_data = squeeze( tot_data(nch, :) );
            filtered_data( nch, :) = Gaussian_PCM_fil( select_data, t, center_freq, full_bandwidth, drive_voltage_source_conjfft);
            
        end
        
    end
    
    %%       Part 4.3 Beamform raw, filtered or compressed data
    if Option_beamform == 1
        th = [-177:-3 3:177];   %angle in XY plane
        fai = 90;               %angle in XZ plane
        dt = t(2)-t(1);         %1/fs
        cw = 1525;              %sound speed
        
        % % % % % % % % %%%%%%%%%%%%Get the array shape  %%%%%%%%%%%%%%%%%%%%%%%%%
        % % % get array shape aprameter with Newfora_spv_trip, provided by original author and changed by us for channel selection.
        [Y_a,X_a,Z_a] = Newfora_spv_trip(Roll_T2,Roll_T2,TripInUseChn0,TripInUseChn1,TripInUseDtChn);%% this one looks right based on the left-right discrimination of the result.
        Y_a = -1*Y_a;
        
        %   Define a moving Gaussian window, with the size of 1/bandwidth,
        %   to take in small chunk of data and beamform. Provide the total
        %   number of Gaussian windows given the signal recording time.
        [Gaus_window,Npts,N_win,step_size,t_win] = func_gen_Gaussian_window( tau, t, sample_freq);
        r_win    =  t_win * cw;
        
        %    Beamforming with moving Gaussian window, stepsize tau = 1/bandwidth
        clear select_data;
        
        for nwin = 1:N_win
            for nch =1:TripInUseChNum
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                select_data(nch,:) = reshape( filtered_data( nch,(nwin-1)*step_size+[1:Npts] ),1,Npts ).*( Gaus_window ); %% Gaussian window
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            beamform(nwin,:) = 2*sum(abs(Cardioid_beamformer_foraTrip_INFreq_Domain(select_data,X_a,Y_a,Z_a,fai,th,dt,cw,max(center_freq-full_bandwidth/2,1),min(center_freq+full_bandwidth/2,1/dt*0.5))).^2,2);
        end
        
        
        %%       Part 4.4 Normalization and 3.18 deg magnetic correction
        
        normalization_factor = (Npts*dt/tau)*10;  % Npt=length of Gaussian window, dt=1/fs, tau=1/full_bandwidth
        ang_int = 10*log10( beamform * normalization_factor) + 46.95-GainSet;
        
        AngleOfArray = 180 - process_heading + 3.18;        %% subtract 3.18 deg magnetic correction, NOT add
                                                            %% fixed heading is used instead of using heading sensor data
        
        
        %%       Part 4.5 Plot 360deg beamed reverb with bathy and clutter objects,
        
        Y = 0.5*r_win'*cos((th-AngleOfArray)*pi/180);
        X = 0.5*r_win'*sin((th-AngleOfArray)*pi/180);
        
        % load in bathymetry map and clutter objects
        [Map_X,Map_Y,Map_Z,wrecgps] = func_load_map_targets(M2);
        
        figure(30);
        Rmax_map = 8000;%sqrt(max( max(X.^2+Y.^2))); Max range for plotting in meters.
        
        func_plot_360beam_bathy(Rmax_map,Map_X,Map_Y,Map_Z,wrecgps,X,Y,ang_int);
        
        Title_name1 =  all_datafiles(nsig).name;
        title([Title_name1(1:end-4)  ' F_c: ', num2str(center_freq),'Hz, FBW: ', num2str(full_bandwidth),' Hz'],'fontsize',14);
        
        
        %%       Part 4.6 Save beamed data and figures. Parameters are saved to structure array "BeamformResult"
        BeamformResult.t_win = t_win;
        BeamformResult.r_win = r_win;
        BeamformResult.X = X;
        BeamformResult.Y = Y;
        BeamformResult.Title_name1 = Title_name1;
        BeamformResult.beamform = beamform;
        BeamformResult.theta = th;
        BeamformResult.fai = fai;
        BeamformResult.AngleOfArray = AngleOfArray;
        
        BeamformResult.filtered_data = filtered_data;
        BeamformResult.angular_int = ang_int;
        BeamformResult.center_freq = center_freq;
        BeamformResult.twosided_bandwidth = full_bandwidth;
        BeamformResult.F1 = F1;
        BeamformResult.F2 = F2;
        BeamformResult.PL = PL;
        BeamformResult.Taper = Taper;
        BeamformResult.sample_freq = sample_freq;
        BeamformResult.tau = tau;
        
        outpt_name = ['beam_',Title_name1(1:end-4)];
        BeamformResult.outpt_name = outpt_name;
        
        save( [resultpathname,'\',outpt_name],'BeamformResult','pathname','data_filename');
        figure(30);
        saveas( gcf,[resultpathname,'\',outpt_name], 'tif');
    end
    
end

