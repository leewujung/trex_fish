function h = Gaussian_PCM_fil(s0,t,f0,dF,drive_voltage_source_conjfft)

% s0   signal to be pulse compressed
% t    time of each sample point [sec]
% f0   center frequency
% dF   full bandwidth
% drive_voltage_source_conjfft   pulse compression template


Nt = length(s0);
dt = t(2)-t(1);
df = 1/(Nt*dt);

f = [0:Nt-1]*df;   % frequency vector
s = (dF/2)/sqrt(log(2));  % std for Gaussian window
S = fft(s0);
G = exp(-(f-f0).^2/(2*s^2));  % Gaussian window in freq
G(floor((Nt+1)/2):end) = 0;
h = 2*real(ifft(G.*S.*drive_voltage_source_conjfft));


