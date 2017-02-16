function spec = get_spectrum_mtm(sig,fs,win_perc)
% Get spectrum using multitape method and compensate for source level
% 
% INPUT
%   sig        input signal
%   fs         sampling frequency [Hz]
%   win_perc   percentage of the window function wrt signal length
% 
% Wu-Jung Lee | leewujung@gmail.com
% 2017 01 25  revised from old code


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
pxx_mean = mean(pxx,2);

spec.freq_vec = f;
spec.pxx = pxx;
spec.pxx_mean = pxx_mean;

