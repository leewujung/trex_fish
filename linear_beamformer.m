function beam = linear_beamformer(data,X_a,Y_a,Z_a,th,dt,cw,f0,f1)
% size(data) = Nch x nfft
% th a vector of angle in degrees. Broadside: th = 0   (Y positive direction)
% dt data sampling interval  dt = 1/fs  fs : sample frequency.
% fai is the angle for roll  angle  from the X-Y plane
% fai can be just one angle, th can be a vector. 
% X_a,Y_a,Z_a, array shape parameter
% cw soun dspeed
% f0 frequency band low boundary
% f1 frequency band high  boundary
% considering the pre-filter for the filter f0 and f1 is set just to reduce the calculation consuming

% Wu-Jung Lee | leewujung@gmail.com
% 2016/06/23  Modify from Jie's triplet beamformer

X_a = X_a(:).';
Y_a = Y_a(:).';
Z_a = Z_a(:).';
th = th/180*pi;

%nfft = pow2(nextpow2(length(data(1,:))));
nfft = length(data(1,:));
if mod(nfft,2) ~= 0
    nfft = nfft+1;
end

D1fft = ifft(data,nfft,2);
df = 1/(nfft*dt);
f = [0:nfft-1]*df;
D1fft(:,nfft/2+1:end) = 0;
k = 2*pi*f/cw;

[tf0 nf0] = min(abs( f - f0 ));
[tf1 nf1] = min(abs( f - f1 ));
find = (nf0(1)):1:(nf1(1));

nth = length(th);

beam = zeros(nth,length(find));


X_amean = mean(X_a);
Y_amean = mean(Y_a);
Z_amean = mean(Z_a);

dY = Y_a-mean(Y_a);


for iTH=1:length(th)    
    phase_delay = exp(1j*dY'*sin(th(iTH))*k(find));
    beam(iTH,:) = mean(D1fft(:,find).*phase_delay,1);
    % note using 'mean' here instead of 'sum' to account for
    % beamforming level change
end



