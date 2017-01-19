function pulse_cw = gen_theoretical_waveform(sample_freq, desired_pulse_start_freq_khz, desired_pulse_stop_freq_khz, desired_pulse_duration_ms, percent_taper)

desired_pulse_start_freq = desired_pulse_start_freq_khz*1000;
desired_pulse_stop_freq = desired_pulse_stop_freq_khz*1000;
desired_pulse_duration = desired_pulse_duration_ms/1000;

num_of_points = sample_freq * desired_pulse_duration;
dt = 1/sample_freq;

% Make array of times to sample waveform
sampling_time=0:1:num_of_points-1;
sampling_time=sampling_time*dt;

% Create pulse 
%pulse_cw=sin(2*pi*desired_pulse_freq*tid);

pulse_cw = chirp(sampling_time, desired_pulse_start_freq, desired_pulse_duration,...
    desired_pulse_stop_freq, 'linear', -90);

%Add last zero sample
pulse_cw=[pulse_cw 0];


%****************************************************************************************
% Do calculations for plots
%****************************************************************************************
%make time scale
time = 0:1:num_of_points;       % includes zero value at end of waveform added above
time_ms = (time * dt)* 1000;

%****************************************************************************************
% Apply cosine taper to pulse
%****************************************************************************************
n = length(pulse_cw);
taper = ones(1,n);

nwin = fix( n * percent_taper/100 );

for i = 1:nwin
    % taper front of pulse
	taper(i) = .5 * ( 1. - cos( pi*(i-1)/nwin ) );
    % taper end of pulse
	taper(n-i+1) = taper(i);
end
pulse_cw = pulse_cw .* taper;

%****************************************************************************************
% Plot time series
%****************************************************************************************
time = 0:1:length(pulse_cw)-1;
time_ms = (time * dt)* 1000;

% figure(6);
% plot(time_ms, pulse_cw);
% ylabel('Amplitude');
% xlabel('Time (ms)');
% title('Time Series after Amplitude Tapering');
% zoom on;
% grid on;

%****************************************************************************************
% Save data to file
%****************************************************************************************
% filename = sprintf('FM_PULSE_F1_%05.2f_F2_%05.2f_PL%05.2f_T%05.2f.arb', ...
%     desired_pulse_start_freq_khz, desired_pulse_stop_freq_khz,...
%     desired_pulse_duration_ms, percent_taper);
% fid_pulse = fopen(filename, 'wt');
% fprintf(fid_pulse, '%E\n', pulse_cw);
% fclose(fid_pulse);

