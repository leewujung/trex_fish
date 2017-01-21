
drive = drive_voltage_source;
drive_fft = fft(drive);
drive_psd = (1/data.sample_freq/length(drive_fft))*abs(drive_fft).^2;
dt = 1/data.sample_freq;
df = data.sample_freq/length(drive_fft);
freq_drive = (0:length(drive_fft)-1)*df;

energy_in_time = sum(abs(drive).^2)*dt;
energy_in_freq = sum(drive_psd)*df;

parseval_in_time = sum(abs(drive).^2);
parseval_in_freq = (1/length(drive_fft))*sum(abs(drive_fft).^2);

% Note: dt = df/sample_freq, this is important in converting the energy
% conservation from DFT parseval theorem to using the actual energy content
% with real units.

max_in_beam_mf = max(20*log10(abs(hilbert(beam_mf_in_time(:,68)))));
gain_beamform
max_in_drive_acorr = max(20*log10(abs(hilbert(sig_mf_in_time(:,1)))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
20*log10(parseval_in_time) =...
    20*log10(parseval_in_freq) =...
    max_in_drive_acorr =...
    max_in_beam_mf-gain_beamform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% these values are all ~86.7990 = 2*43.3995

max_in_drive_spectrum_uncal = max(10*log10(abs(drive_fft).^2));
drive_spectrum_uncal = 10*log10(abs(drive_fft).^2);
10*log10(sum(abs(drive_fft).^2));

want_idx=20*log10(abs(drive_fft))>58;
bandwidth_in_freq_pt = sum(want_idx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 90.2043 - 10*log10(fft_len) = 43.3995
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% (43.3995 is the DFT parseval energy)
max_in_drive_spectrum_uncal + 10*log10(bandwidth_in_freq_pt) =...
    10*log10(sum(abs(drive_fft).^2)) =...
    10*log10(sum(10.^(drive_spectrum_uncal/10)))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% these values are all ~90.2043

% Now treating the half of drive copy in the simluated time series as the
% received signal. To get the parseval level of the received signal right,
% the total energy has to be subtracted by the parseval level of the
% template (drive). 




