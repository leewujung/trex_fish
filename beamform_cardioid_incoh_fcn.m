% 2016 06 16  Beamform from raw data, linear processing only, not triplet
% 2016 09 15  
% 2017 01 06  Change to cardioid beamforming based on beamform_linear_incoh.m
% 2017 01 14  Clean up code
%             Take out video plotting parts and stuff related to 'wfm'

function beamform_cardioid_incoh_fcn(beamform_angle,run_num,ping_num,base_save_path,base_data_path)

addpath(['./Triplet_processing_toolbox'])
if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
end

plot_opt = 0;

%% Setting param and paths to read file
run_num = 131;

TripInUseDtChn = 1;  %  1-triplet, 3-array
TripInUseChn0 = 91;     % start channel NO.
TripInUseChn1 = 234;    % end channel NO.
TripInUseChNum = length([TripInUseChn0:TripInUseDtChn:TripInUseChn1]);

t_start = 0;   % start time within ping
t_end  =  20;  % end time within ping

cw = 1525;  % sound speed

M2     =  [30.0599; -85.6811]; % GPS location of the array

% beamform_angle = [-177:-3 3:177];   % beamform angle in XY plane
% beamform_angle = 90;
phi = 90;               % beamform angle in XZ plane

param.run_num = run_num;
param.TripInUseDtChn = TripInUseDtChn;
param.TripInUseChn0 = TripInUseChn0;
param.TripInUseChn1 = TripInUseChn1;
param.TripInUseChNum = TripInUseChNum;
param.t_start = t_start;
param.t_end = t_end;
param.cw = cw;
param.map_coord = M2;
param.beamform_angle = beamform_angle;
param.phi = phi;

% Get processing heading
if run_num <= 53     % Fixed heading for different runs
    process_heading = 219;
elseif run_num > 53 & run_num <= 62
    process_heading = 333;
else
    process_heading = 353;
end

% Set system and loading gain
if run_num>=41
    gain_sys = 12;
else
    gain_sys = 18;
end
gain_load = 46.95;  % when FORA driven as triplet array

param.process_heading = process_heading;
param.gain_sys = gain_sys;
param.gain_load = gain_load;

% Set save folder
[~,script_name,~] = fileparts(mfilename('fullpath'));
script_name = script_name(1:end-4);
save_path = fullfile(base_save_path, ...
                     sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end



%% Set data path and read ECF
full_data_path = fullfile(base_data_path,sprintf('r%d',run_num));
ecf_file = dir([full_data_path,filesep,'*.ecf']);
[waveform_name,waveform_amp,Nrep,digit_timesec,delay_timems,allsignal_info] = ...
    func_read_ECF(fullfile(full_data_path,ecf_file.name));

all_datafiles = dir([fullfile(full_data_path, '*.DAT')]);   %% find all .dat files
if size(all_datafiles) ~= size(allsignal_info,1)   %% make sure .dat match transmission
    disp('Total number of pings does not match ECF file. Something is wrong.');
    return;
end

param.full_data_path = full_data_path;



%% Data processing loop
if plot_opt
    fig_polar = figure('position',[150,80,900,700]);
end

want_file_idx = ping_num;  % index of file to be processed in the whole folder
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
    [Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,...
     sample_freq,sample_time_ms,tot_data] = ...
        func_load_raw_FORA_data(full_data_path, all_datafiles, nsig, t_start, t_end,...
                                TripInUseChn0,TripInUseDtChn,TripInUseChn1);
    Nt = length(sample_time_ms);
    t = sample_time_ms/1000;

    data.Roll_T1 = Roll_T1;
    data.Roll_T2 = Roll_T2;
    data.Heading_T1 = Heading_T1;
    data.Heading_T2 = Heading_T2;
    data.GLAT = GLAT;
    data.GLON = GLON;
    data.sample_freq = sample_freq;
   
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


    % generate drive voltage, conjugate FFT for later compression and
    % normalization the drive voltage peak to 1  (To LFM signals, peak
    % is at the edges of pass and stop bands. This induces less than
    % half dB in comparison with normalization using energy.)
    drive_voltage_source = gen_theoretical_waveform(sample_freq, F1, F2, PL, Taper);
    drive_voltage_source_conjfft = conj(fft(drive_voltage_source, size(tot_data,2)));
    drive_voltage_source_conjfft = drive_voltage_source_conjfft/...
        max( abs(drive_voltage_source_conjfft) ); % filter function with 
                                                  % normalization applied!

    tx_sig.drive_voltage_source = drive_voltage_source;
    tx_sig.drive_voltage_source_conjfft = drive_voltage_source_conjfft;


    % Pulse compression
    filtered_data = zeros(TripInUseChNum, size(tot_data,2));
    for nch = 1:TripInUseChNum
        select_data = squeeze(tot_data(nch, :));
        filtered_data(nch,:) = ...
            Gaussian_PCM_fil(select_data,t,center_freq,...
                             full_bandwidth,drive_voltage_source_conjfft);
    end
    clear select_data;


    % Beamform pulse compressed data
    dt = t(2)-t(1);         %1/fs
 
    % Get array shape parameter with Newfora_spv_trip
    % provided by original author and changed by us for channel selection.
    [Y_a,X_a,Z_a] = Newfora_spv_trip(Roll_T2,Roll_T2,...
                                     TripInUseChn0,TripInUseChn1,TripInUseDtChn);
    Y_a = -1*Y_a;  % NOTE: this change angle definition orientation
                   % this line is from Jie's original code
    array_coord = [X_a',Y_a',Z_a'];
    param.array_coord = array_coord;    


    % Define a moving Gaussian window, with the size of 1/bandwidth,
    % to take in small chunk of data and beamform. Provide the total
    % number of Gaussian windows given the signal recording time.
    [Gaus_window,Npts,N_win,step_size,t_win] = ...
        func_gen_Gaussian_window(tau,t,sample_freq);
    param.Gaus_window = Gaus_window;
    param.Npts = Npts;
    param.N_win = N_win;
    param.step_size = step_size;
    data.t_win = t_win;  % save this to 'data' to go with r_win

    %  Beamforming with moving Gaussian window, stepsize tau = 1/bandwidth
    for nwin = 1:N_win
        for nch = 1:TripInUseChNum
            select_data(nch,:) = ...
                reshape( filtered_data(nch,(nwin-1)*step_size+[1:Npts]),...
                         1,Npts ).*Gaus_window; % Gaussian window
        end
        beamform(nwin,:) = 2*sum(abs(...
            Cardioid_beamformer_foraTrip_INFreq_Domain(select_data,X_a,Y_a,Z_a,...
            phi,beamform_angle,dt,cw,max(center_freq-full_bandwidth/2,1),...
            min(center_freq+full_bandwidth/2,1/dt*0.5))).^2,2);  % sum across frequency
    end
    data.beamform_nocal = beamform;

    % normalization
    normalization_factor = (Npts*dt/tau)*10;  % Npt=length of Gaussian window
                                              % dt=1/fs, tau=1/full_bandwidth
    beamform = 10*log10( beamform * normalization_factor) + gain_load-gain_sys;

    data.beamform = beamform;

    % Determine location to discard data
    [~,idx_max] = max(mean(beamform,2));
    if t_win(idx_max)-1>0.5  % if the peak isat  ~2 sec (very rare)
        idx_t_win_to_cut = find(t_win>2,1,'first');
        r_win = (t_win-2)*cw/2;  % range adjusted to 1 sec after transmission
    else
        idx_t_win_to_cut = find(t_win>1,1,'first');
        r_win = (t_win-1)*cw/2;  % range adjusted to 1 sec after transmission
    end

    data.cut_idx = idx_t_win_to_cut;
    data.range_beam = r_win;

    % Angle routines modifided from Jie's code
    AngleOfArray = 180 - process_heading;
    Y = r_win'*cos((beamform_angle-AngleOfArray)*pi/180);
    X = r_win'*sin((beamform_angle-AngleOfArray)*pi/180);

    data.X = X;
    data.Y = Y;
    data.AngleOfArray = AngleOfArray;

    % Save results
    data = orderfields(data);
    param = orderfields(param);
    tx_sig = orderfields(tx_sig);
        
    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,nsig);  % data
    save(fullfile(save_path,[save_fname,'.mat']),'param','tx_sig','data');


    % Polar energy plot for this ping
    if plot_opt
        %r_win_adj = r_win(idx_t_win_to_cut:end);
        beamform_adj = beamform(idx_t_win_to_cut:end,:);
        
        beamform_adj_detrend = beamform_adj +...  % detrend, ad-hoc 
            repmat(30*log10(r_win'),1,size(beamform_adj,2));

        % load in bathymetry map and clutter objects
        [Map_X,Map_Y,Map_Z,wrecgps] = func_load_map_targets(M2);
        
        cla
        h1 = pcolor(X,Y,beamform_adj_detrend);  % plot echoes
        set(h1,'edgecolor','none')
        hold on
        h1m = pcolor(X_mir,Y_mir,beamform_adj_detrend);  % plot echoes
        set(h1m,'edgecolor','none')
        [c,h2]=contour(Map_X/1000,Map_Y/1000,Map_Z,[0:-2:-30],'k');  % plot map contour
        clabel(c,h2,'fontsize',8,'linewidth',1,'Color','k');
        colormap(jet)
        colorbar
        caxis([180 210])
        axis equal
        xlabel('Distance (km)');
        ylabel('Distance (km)');
        axis([-11 11 -11 11])
        title(sprintf('Ping %04d, local time %02d:%02d:%02d',...
            nsig,time_hh_local,time_mm_local,time_ss_local));
        hold off
        
        saveSameSize_100(gcf,'file',fullfile(save_path,save_fname),...
            'format','png');
        %saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
    end
    
end  % loop through all pings

