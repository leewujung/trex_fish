function spec = get_spectrum_mtm(sig,fs,win_perc,SL)
% Get spectrum using multitape method and compensate for source level
% INPUT
%   sig        input signal
%   fs         sampling frequency [Hz]
%   win_perc   percentage of the window function wrt signal length
%   SL         source level obtained using get_SL.m
% 
% Wu-Jung Lee | leewujung@gmail.com
% 2017 01 25  revise


fft_len = size(sig,1);
win_len = round(fft_len*win_perc);
win = hann(win_len);
win = [win(1:ceil(win_len/2));ones(fft_len-win_len,1);win(ceil(win_len/2)+1:end)];

if 0
    % ------ Use FFT to estimate spectrum --------
    fft_len_half = round((fft_len+1)/2);
    sig_freq_vec = (0:fft_len_half-1)*fs/fft_len;

    sig_fft = fft(sig.*repmat(win,1,size(sig,2)));
    sig_fft_dB = 10*log10(2*abs(sig_fft(1:fft_len_half,:)).^2/fft_len);
    sig_psd_dB = 10*log10(2*abs(sig_fft(1:fft_len_half,:)).^2/fft_len/fs);

    sig_fft_dB_incoh_mean = 10*log10( mean(10.^(sig_fft_dB/10),2) );
    sig_psd_dB_incoh_mean = 10*log10( mean(10.^(sig_psd_dB/10),2) );
end

% ------ Use MULTITAPER method to estimate spectrum --------
[pxx,f] = pmtm(sig.*repmat(win,1,size(sig,2)),[],[],fs);
pxx_mean = mean(abs(pxx),2);
pxx_dB = 10*log10(pxx);
pxx_dB_mean = 10*log10(pxx_mean);

% Compensate for SL
SL_psd_comp = interp1(SL.freq,SL.SL_psd,f);
pxx_dB_mean_SL_comp = pxx_dB_mean-SL_psd_comp;

spec.freq_vec = f;
spec.pxx = pxx;
spec.pxx_mean = pxx_mean;
spec.pxx_dB_mean_SL_comp = pxx_dB_mean_SL_comp;
