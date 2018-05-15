function S = get_SL(run_num,ping_num)
% Get source level for a particular run
%
% Wu-Jung Lee | leewujung@gmail.com
% 2016 11 21
% 2017 01 23  Clean up
% 2017 02 19  Enable loading each individual MON file for each ping
% 2018 05 15  Add files for run 129 & 130
%             Note exception for run 130 --don't process ping_num<95

% Load transmit waveform
if isunix
    amp_mon_path = '~/internal_2tb/trex/HAARI_data/Amp_mon_data';
else
    amp_mon_path = 'F:\trex\HAARI_data\Amp_mon_data';
end

switch run_num
  case 79
    amp_mon_subpath = 'TREX13_MON_13-05-09_21-27-05-925';
  case 87
    amp_mon_subpath = 'TREX13_MON_13-05-10_17-54-44-701';
  case 94
    amp_mon_subpath = 'TREX13_MON_13-05-11_20-09-48-855';
  case 103
    amp_mon_subpath = 'TREX13_MON_13-05-12_19-07-57-592';
  case 115
    amp_mon_subpath = 'TREX13_MON_13-05-13_20-40-15-101';
  case 120
    amp_mon_subpath = 'TREX13_MON_13-05-14_21-27-37-260';
  case 124
    amp_mon_subpath = 'TREX13_MON_13-05-15_21-11-39-716';
  case 129
    amp_mon_subpath = 'TREX13_MON_13-05-16_14-59-11-817';
  case 130
    amp_mon_subpath = 'TREX13_MON_13-05-16_16-52-54-133';
  case 131
    amp_mon_subpath = 'TREX13_MON_13-05-16_18-28-07-368';
end
if run_num==130
    if ping_num < 95
        S = [];
        return
    else
        ping_num = ping_num-94;
    end
    amp_mon_file = sprintf('TREX13_MON_I%05d-restart_P%05d.mat',run_num,ping_num);
elseif run_num==129
    S = [];
    return    
else
    amp_mon_file = sprintf('TREX13_MON_I%05d_P%05d.mat',run_num,ping_num);
end

A = load(fullfile(amp_mon_path,amp_mon_subpath,amp_mon_file));

tx_fft = fft(A.ad_data_converted(:,1)*...  % ch0: voltage, ch1: current
             A.ch_0_voltage_scale_factor);
tx_fft_len_half = round((length(tx_fft)+1)/2);

tx_fft_dB = 10*log10(2*abs(tx_fft(1:tx_fft_len_half).^2/length(tx_fft)));
tx_psd_dB = 10*log10(2*abs(tx_fft(1:tx_fft_len_half).^2/length(tx_fft))/A.actual_ad_sample_rate);

tx_freq = linspace(0,A.actual_ad_sample_rate,length(tx_fft));
tx_freq = tx_freq(1:tx_fft_len_half);

tx_rms_dB = 20*log10(rms(A.ad_data_converted(:,1))*...
                     A.ch_0_voltage_scale_factor);
tx_rms = rms(A.ad_data_converted(:,1))*A.ch_0_voltage_scale_factor;

% Load TVR
get_TVR_ITC2015
tvr_interp = interp1(TVR.freq*1e3,TVR.tvr,tx_freq).';

% Calc SL
SL = tx_fft_dB + tvr_interp;
SL_psd = tx_psd_dB + tvr_interp;

S.SL = SL;
S.SL_psd = SL_psd;
S.freq = tx_freq;
