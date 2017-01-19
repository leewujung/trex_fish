function beam = Cardioid_beamformer_foraTrip_INFreq_Domain(data,X_a,Y_a,Z_a,fai,th,dt,cw,f0,f1)
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

X_a = X_a(:).';
Y_a = Y_a(:).';
Z_a = Z_a(:).';

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
Nfai = length(fai);

beam = zeros(nth,length(find));

if(rem(length(X_a),3) ~=0)
    disp('A triplet array is needed!');
    return;
end

for n = 1:floor(length(X_a)/3)
     X_amean(3*(n-1)+[1:3]) = mean(X_a(3*(n-1)+[1:3]));
     Y_amean(3*(n-1)+[1:3]) = mean(Y_a(3*(n-1)+[1:3]));
     Z_amean(3*(n-1)+[1:3]) = mean(Z_a(3*(n-1)+[1:3]));
end

    dtX_a = X_a - X_amean;
    dtY_a = Y_a - Y_amean;
    dtZ_a = Z_a - Z_amean; 
    
    R = 0.0222;
    
    
for n = 1:1
    
     R =  sqrt((dtX_a(3*(n-1)+1)-dtX_a(3*(n-1)+2)).^2+(dtY_a(3*(n-1)+1)-dtY_a(3*(n-1)+2)).^2+(dtZ_a(3*(n-1)+1)-dtZ_a(3*(n-1)+2)).^2)...
         +sqrt((dtX_a(3*(n-1)+1)-dtX_a(3*(n-1)+3)).^2+(dtY_a(3*(n-1)+1)-dtY_a(3*(n-1)+3)).^2+(dtZ_a(3*(n-1)+1)-dtZ_a(3*(n-1)+3)).^2)...
         +sqrt((dtX_a(3*(n-1)+3)-dtX_a(3*(n-1)+2)).^2+(dtY_a(3*(n-1)+3)-dtY_a(3*(n-1)+2)).^2+(dtZ_a(3*(n-1)+3)-dtZ_a(3*(n-1)+2)).^2);
     R = R/3/(sqrt(3));
     
end


    dtpos = [dtX_a.',dtY_a.',dtZ_a.']; 
    
    th  = th*pi/180;
    fai = fai*pi/180;
    
for ith = 1:Nfai

    for jth = 1:nth

% 
%         ph0  = exp( +i * (  X_amean' * sin(fai(ith))*sin(th(jth))     + Y_amean' * sin(fai(ith))*cos(th(jth))       + Z_amean' *cos(fai(ith)) ) * k(find) );
%         phdt = exp( i * (  dtX_a'  * sin(fai(ith))*sin(2*pi-th(jth)) + dtY_a'   * sin(fai(ith))*cos(2*pi-th(jth))  + dtZ_a'   *cos(fai(ith)) ) * k(find) );

        ph0  = exp( +i * (  X_amean' *sin(th(jth))     + Y_amean' *cos(th(jth)) ) * k(find) );
        phdt = exp( i * (  dtX_a'  *sin(2*pi-th(jth)) + dtY_a'   * cos(2*pi-th(jth)) ) * k(find) );

        
%         amp = dtpos*[sin(fai(ith))*sin(th(jth)) sin(fai(ith))*cos(th(jth)) cos(fai(ith))].';%.*(6*pi*f(find)*(R*sin(th(jth)).^2))/cw;
        amp = dtpos*[sin(th(jth)) cos(th(jth)) 0].';%.*(6*pi*f(find)*(R*sin(th(jth)).^2))/cw;

%         for m=1:size(ph0,2)
% %             ph(:,m) = ph0(:,m).* phdt(:,m).*amp(:);
%             ph(:,m) = ph0(:,m).* phdt(:,m).*amp(:)/(( 6*pi*f( find(m) ) * (R*sin(th(jth))).^2 )/cw);
%         end
%         
%         Dth = D1fft(:,find).*ph;
%         beam(jth,:) = mean(Dth,1);

        for m=1:size(ph0,2)
            
            ph(:,m) = ph0(:,m).* phdt(:,m).*amp(:) / f( find( m ) );
            
        end
        
           ph = ph/(( 6*pi * (R*sin(th(jth))).^2 )/cw);

           Dth = D1fft(:,find).*ph;
           beam(jth,:) = mean(Dth,1);

    end
    
    
end


return

