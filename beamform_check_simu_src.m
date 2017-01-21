% 2017 01 18  Produce simulated data to check beamforming results

if ismac
    base_data_path = '~/Downloads';
else
    base_data_path = '~/internal_2tb/trex/figs_results/';
end

p = mfilename('fullpath');
pp=fileparts(p);
addpath(fullfile(pp,'Triplet_processing_toolbox'));

bf=0;
if bf==0
    base_data_path = fullfile(base_data_path,...
                      'beamform_linear_coherent_run131');
    data_file = 'beamform_linear_coherent_run131_ping0150.mat';
else
    base_data_path = fullfile(base_data_path,...
                      'beamform_linear_coherent_run131');
    data_file = 'beamform_cardioid_coherent_run131_ping0150.mat';
end
load(fullfile(base_data_path,data_file));

data.sample_freq = 4*data.sample_freq;

% Generate simulated signals
tx_sig.drive_voltage_source = ...
    gen_theoretical_waveform(data.sample_freq,tx_sig.F1,tx_sig.F2,tx_sig.PL,tx_sig.Taper);

src_dist = 3e3;  % source distance [m]
src_angle = 20;  % source angle from east [deg]
src_loc = src_dist*[cos(src_angle/180*pi),sin(src_angle/180*pi),0];
simu_dist = 10e3;  % simulation total distance [m]
simu_len = round(simu_dist/param.cw*data.sample_freq);
sig = zeros(simu_len,size(param.array_coord,1));

dist = sqrt(sum((param.array_coord-...
                 repmat(src_loc,size(param.array_coord,1),1)).^2,2));
time_start_idx = round(dist/param.cw*data.sample_freq);

for iM=1:size(param.array_coord,1)
    time_idx = time_start_idx(iM)+[0:length(tx_sig.drive_voltage_source)-1]; 
    sig(time_idx,iM) = tx_sig.drive_voltage_source; 
end
sig_n = sig+randn(size(sig))*0.2;


% Perform beamforming
seg = sig;
x_a = param.array_coord(:,1)';
y_a = param.array_coord(:,2)';
%y_a = y_a - mean(y_a);
z_a = param.array_coord(:,3)';
del_y = y_a-mean(y_a);


% fft
seg_fft = fft(seg);
seg_len = size(seg,1);
seg_len_half = floor((seg_len+1)/2);
dt = 1/data.sample_freq;
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


if bf==0
    % Beamforming [linear]
    beamform_angle = -87:1:87;
    k_seg = 2*pi*freq_seg/param.cw;
    seg_fft_beam = nan(seg_len_half,length(beamform_angle));
    for iB=1:length(beamform_angle)
        disp(['angle = ',num2str(beamform_angle(iB)),' deg'])
        phase_delay = exp(1j*k_seg'*del_y*sin(beamform_angle(iB)/180*pi));
        seg_fft_beam(:,iB) = sum(seg_fft.*phase_delay,2);
    end
    seg_fft_beam_pad = [seg_fft_beam;...
                        flipud(conj(seg_fft_beam(2:end,:)))];
    beam_in_time = ifft(seg_fft_beam_pad);
else
    % Beamforming [cardioid]
    beamform_angle = [-177:3:-3 3:3:177];
    phi = 90/180*pi;  % vertical beamform angle [rad]
    k_seg = 2*pi*freq_seg/param.cw;
    seg_fft_beam = nan(seg_len_half,length(beamform_angle));
    for iB=1:length(beamform_angle)
        disp(['angle = ',num2str(beamform_angle(iB)),' deg'])
        u = [sin(phi)*sin(beamform_angle(iB)/180*pi);...
             sin(phi)*cos(beamform_angle(iB)/180*pi);...
             cos(phi)];
        u_vjk_phase = [x_a',y_a',z_a']*u;
        u_vjk_amp = [dx',dy',dz']*u;
        phase_delay = exp(-1j*k_seg.'*u_vjk_phase.');
        amp = repmat(u_vjk_amp.',size(seg_fft,1),1);
        calib_fac = 6*pi*freq_seg * (r*sin(beamform_angle(iB)/180*pi)).^2 /param.cw;
        calib_fac = repmat(calib_fac.',1,size(seg_fft,2));
        seg_fft_beam(:,iB) = sum(seg_fft.*phase_delay.*amp./calib_fac,2);
        nanidx = isnan(seg_fft_beam(:,iB));
        seg_fft_beam(nanidx,iB) = 0;
    end
    seg_fft_beam_pad = [seg_fft_beam;...
                        flipud(conj(seg_fft_beam(2:end,:)))];
    beam_in_time = ifft(seg_fft_beam_pad);
end

% Pulse compression
drive_voltage_source = tx_sig.drive_voltage_source;
tmp = conj(fft(drive_voltage_source, seg_len));
tmp = tmp(1:seg_len_half);
seg_fft_beam_mf = seg_fft_beam.*repmat(tmp.',1,size(seg_fft_beam,2));
seg_fft_beam_mf_pad = [seg_fft_beam_mf;...
                    flipud(conj(seg_fft_beam_mf(2:end,:)))];
beam_mf_in_time = ifft(seg_fft_beam_mf_pad);
mf_len = size(beam_mf_in_time,1);

sig_fft = fft(sig);
sig_fft = sig_fft(1:seg_len_half,:);
sig_fft_mf = sig_fft.*repmat(tmp.',1,size(sig_fft,2));
sig_fft_mf_pad = [sig_fft_mf;...
                    flipud(conj(sig_fft_mf(2:end,:)))];
sig_mf_in_time = ifft(sig_fft_mf_pad);


% Gain factors for beamforming and pulse compression
tmp_freq = (0:seg_len_half-1)*df;
[~,fcind] = min(abs(tmp_freq-tx_sig.center_freq));
gain_pc = 20*log10(abs(tmp(fcind)));      % pulse compression gain
if bf==0
    gain_beamform = 20*log10(size(seg,2));  % beamforming gain
else
    gain_beamform = 20*log10(size(seg,2)/3);  % beamforming gain
end

% Range
rr_data = (0:length(beam_mf_in_time)-1)/data.sample_freq*param.cw/2;

% Smoothing and subsampling
% Get envelope
for iA=1:size(beam_mf_in_time,2)
    disp(['iA=',num2str(iA)]);
    tmpenv = smooth(beam_mf_in_time(:,iA),100);
    tmpenv = tmpenv(1:100:end);
    bf_env_sm(:,iA) = abs(hilbert(tmpenv));
end


% Get angle for plotting
process_heading = 0;
if bf==0
    polar_angle = process_heading+beamform_angle;
else
    polar_angle = -process_heading-beamform_angle+90;
end
[amesh,rmesh] = meshgrid(polar_angle/180*pi,rr_data(1:100:end)/1000);
[X,Y] = pol2cart(amesh,rmesh);

% Polar energy plot for this ping
figure
cla
h1 = pcolor(X,Y,20*log10(bf_env_sm));  % plot echoes
set(h1,'edgecolor','none')
hold on
%[c,h2]=contour(Map_X/1000,Map_Y/1000,Map_Z,[0:-2:-30],'k');  % plot map contour
%clabel(c,h2,'fontsize',8,'linewidth',1,'Color','k');
%colormap(jet)
colorbar
%caxis([130 170])
axis equal
xlabel('Distance (km)');
ylabel('Distance (km)');


%param.gain_beamform = gain_beamform;
%param.gain_pc = gain_pc;


%run_num = 131;
%nsig = 150;
%t_start = 0;
%t_end = 20;

%full_data_path = fullfile(base_data_path,sprintf('r%d',run_num));
%ecf_file = dir([full_data_path,filesep,'*.ecf']);
%[waveform_name,waveform_amp,Nrep,digit_timesec,delay_timems,allsignal_info] = ...
%    func_read_ECF(fullfile(full_data_path,ecf_file(end).name));

%all_datafiles = dir([fullfile(full_data_path, '*.DAT')]);   %% find all .dat files
%if size(all_datafiles) ~= size(allsignal_info,1)   %% make sure .dat match transmission
%    disp('Total number of pings does not match ECF file. Something is wrong.');
%    return;
%end

%[F1, F2, PL, Taper] = func_extract_signal_info(nsig, allsignal_info);

%[Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,...
% sample_freq,sample_time_ms,tot_data] = ...
%    func_load_raw_FORA_data(full_data_path, all_datafiles, nsig, t_start, t_end,...
%                            TripInUseChn0,TripInUseDtChn,TripInUseChn1);

%drive_voltage_source = gen_theoretical_waveform(sample_freq, F1, F2, PL, Taper);

