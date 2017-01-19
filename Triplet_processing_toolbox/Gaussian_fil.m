function h = Gaussian_fil(s0,t,f0,dF)
Nt = length(s0);
dt = t(2)-t(1);
df = 1/(Nt*dt);

f = [0:Nt-1]*df;
s = (dF/2)/sqrt(log(2));
S = fft(s0);
G = exp(-(f-f0).^2/(2*s^2));
G(floor((Nt+1)/2):end) = 0;
h = 2*real(ifft(G.*S));

%%% The filter should be normalized here.   To be changed by JIE to keep
%%% consistent with the other previous result