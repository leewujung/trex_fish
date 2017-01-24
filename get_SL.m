function S = get_SL(run_num,wfm_num)
% Get source level for a particular run
%
% Wu-Jung Lee | leewujung@gmail.com
% 2016 11 21
% 2017 01 23  Clean up

% Load transmit waveform
if isunix
    amp_mon_path = '~/internal_2tb/trex/Data/Amp_mon_data';
else
    amp_mon_path = 'F:\trex\Data\Amp_mon_data';
end

keyboard

switch run_num
    case 79
        amp_mon_subpath = 'TREX13_MON_13-05-09_21-27-05-925';
        amp_mon_file = 'TREX13_MON_I00079_P00004.mat';
    case 87
        amp_mon_subpath = 'TREX13_MON_13-05-10_17-54-44-701';
        amp_mon_file = 'TREX13_MON_I00087_P00010.mat';
    case 131
        amp_mon_subpath = 'TREX13_MON_13-05-16_18-28-07-368';
        switch wfm_num
            case 1
                amp_mon_file = 'TREX13_MON_I00131_P00009.mat';
            case 2
                amp_mon_file = 'TREX13_MON_I00131_P00010.mat';
        end
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
