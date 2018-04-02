% 2016 08 29  Beampattern prediction comparsion: MF and single freq


clear
if isunix
    addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath(['/home/wu-jung/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/trex_data/TREX13_Reverberation_Package/TREX_FORA_DATA/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\trex_fish\Triplet_processing_toolbox')
    base_save_path = 'F:\trex\figs_results';
    base_data_path = '\\10.95.97.212\Data\TREX13_Reverberation_Package\TREX_FORA_DATA/';
end

% Run params
run_num = 87;
TripInUseDtChn = 3;  %  1-triplet, 3-array
TripInUseChn0 = 91;     % start channel NO.
TripInUseChn1 = 234;    % end channel NO.
TripInUseChNum = length([TripInUseChn0:TripInUseDtChn:TripInUseChn1]);

t_start = 0;   % start time within ping
t_end  =  20;  % end time within ping

% Get data path/files
full_data_path = fullfile(base_data_path,sprintf('r%d',run_num));
ecf_file = dir([full_data_path,filesep,'*.ecf']);
[waveform_name,waveform_amp,Nrep,digit_timesec,delay_timems,allsignal_info] = ...
    func_read_ECF(fullfile(full_data_path,ecf_file.name));

% Set save folder
[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path, ...
    sprintf('%s_run%d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Get all data files
all_datafiles = dir([fullfile(full_data_path, '*.DAT')]);   %% find all .dat files
if size(all_datafiles) ~= size(allsignal_info,1)   %% make sure .dat match transmission
    disp('Total number of pings does not match ECF file. Something is wrong.');
    return;
end

% Set waveform param
wfm = 1;    % waveform data wanted
n_wfm = 1;  % number of waveforms in this run
n_ping = floor(length(all_datafiles)/n_wfm);  % number of pings per waveform

want_file_idx = wfm:n_wfm:length(all_datafiles);  % indices of files to be processed
nsig = want_file_idx(1);

% Load data
[Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,sample_freq,sample_time_ms,tot_data] = ...
    func_load_raw_FORA_data(full_data_path, all_datafiles, nsig, t_start, t_end,...
    TripInUseChn0,TripInUseDtChn,TripInUseChn1);

% Array element positions
[Y_a,X_a,Z_a] = Newfora_spv_trip(Roll_T2,Roll_T2,...
    TripInUseChn0,TripInUseChn1,TripInUseDtChn);
array_coord = [X_a',Y_a',Z_a'];

% Beamform param
th = -87:0.1:87;  % defined from broadside
th = th/180*pi;
% freq = [1.9,2.7,3.4]*1e3;
freq = [1.9:0.1:3.6]*1e3;
cw = 1525;  % sound speed
k = 2*pi*freq/cw;

array_coord_mean = mean(array_coord,1);

dY = array_coord(:,2)-array_coord_mean(2);

for iF=1:length(freq)
    phase_delay(iF,:,:) = exp(1j*dY*sin(th)*k(iF));
    beam(iF,:) = sum(squeeze(phase_delay(iF,:,:)),1);
end
beam_log_norm = 20*log10(abs(beam))-repmat(max(20*log10(abs(beam)),[],2),1,length(th));

beam_mf_incoh = sum(abs(beam).^2,1);

figure
h = plot(th/pi*180,beam_log_norm);
hold on
hmf = plot(th/pi*180,10*log10(beam_mf_incoh)-max(10*log10(beam_mf_incoh)),'r','linewidth',2);
legend(hmf,'MF')
xlim([-20 20])
ylim([-35 3])
grid
xlabel('Beam angle (deg)');
ylabel('Normalized beampattern');

saveas(gcf,...
    fullfile(save_path,[script_name,'.fig']),'fig');
saveSameSize_150(gcf,'file',fullfile(save_path,[script_name,'.png']),...
    'format','png','renderer','painters');

