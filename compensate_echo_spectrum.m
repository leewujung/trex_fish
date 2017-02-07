function ospec = compensate_echo_spectrum(spec,SL,A)
% Compensate for gains contributed by load, system gain, beamforming, pulse
% compression, and SL
%
% INPUT
%   spec  raw echo spectrum in spectral level [dB/Hz]
%   SL    source level obtained by get_SL.m
%   A     beamformed data
%
% Wu-Jung Lee | leewujung@gmail.com
% 2017 01 25  clean up code and put everything together


% Compensation: SL
SL_psd_comp = interp1(SL.freq,SL.SL_psd,spec.freq_vec);

% Compenstation: pulse compression energy increase
% -- Here we don't use the actual spectral density because the goal is to
% -- remove the additional power added by pulse compression in the freq
% -- domain. Therefore we want to subtract the energy contained in the
% -- transmit signal on a freq-by-freq basis.
% -- Also because the beamform time series stored in A.data.beam_mf_in_time
% -- has not been compensated to be 'spectral density'
tx_fft = fft(A.tx_sig.drive_voltage_source);
tx_fft_len_half = round((length(tx_fft)+1)/2);
freq_vec = (0:tx_fft_len_half-1)*A.data.sample_freq/length(tx_fft);
tx_fft_dB = 10*log10(2*abs(tx_fft(1:tx_fft_len_half)).^2);

tx_fft_dB_comp = interp1(freq_vec,tx_fft_dB,spec.freq_vec);

% Compensation for all factors
% -- spec.pxx_mean       -- mean PSD (incoherent averaging)
% -- tx_fft_dB_comp      -- compensation needed to remove additional energy from
%                           pulse compression
% -- SL_psd_comp         -- PSD of source level of transmit signal
% -- param.gain_load     -- gain from load of driving FORA
% -- param.gain_sys      -- system gain
% -- param.gain_beamform -- gain from beamforming 10*log10(48)
spec.pxx_dB_mean_comp = 10*log10(spec.pxx_mean) +...
    A.param.gain_load -A.param.gain_sys -A.param.gain_beamform -...
    tx_fft_dB_comp -SL_psd_comp;

