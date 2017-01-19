function  [xa, ya, za ] = Newfora_spv_trip_wjlee(T1,T2)
%T1,T2 are front and back twist angles
% FORA numbers phones clockwise from 1=top (p30 IRS-part B)
% NURC is opposite sense
% nch_start, NO.1 element channal to be used ( start from 1 )  
%nch_end,    NO.end element channal to be used ( start from 1 )
% nch_dt,    channel 
r = .0222; 
delx = .2;
gamma = 120;
ntrips = 78;
L = (ntrips-1)*delx;
% use Regs convention 1st phone is most positive along x-axis in LHCS
xp = (L/2):-delx:-(L/2);
beta=linspace(T1,T2,ntrips);
for i=1:ntrips
  B(1) = sin(beta(i)*pi/180);
  C(1) = cos(beta(i)*pi/180);
  B(2) = sin((beta(i)+gamma)*pi/180);
  C(2) = cos((beta(i)+gamma)*pi/180);
  B(3) = sin((beta(i)-gamma)*pi/180);
  C(3) = cos((beta(i)-gamma)*pi/180);
  for j=1:3
    X(3*(i-1)+j) = xp(i);
    Y(3*(i-1)+j) = r*B(j);
    Z(3*(i-1)+j) = r*C(j);
  end 
end

xa = X;
ya = Y;
za = Z;
% xa = X(nch_start:nch_dt:nch_end);
% ya = Y(nch_start:nch_dt:nch_end);
% za = Z(nch_start:nch_dt:nch_end);

% % % % % % 
% % % % % % % now has hub delays for FORA
% % % % % % s_p = [1:3*ntrips; X;Y;Z; zeros(1, 3*30) -10.157e-6*ones(1,3*(ntrips-30))]; %trip
% % % % % % fid = fopen('Newfora_spv_trip', 'w');
% % % % % % fprintf(fid, '%d %16.9e %16.9e %16.9e %16.9e\n', s_p);
% % % % % % fprintf(fid, '%s %d %d\n','rolls ',T1,T2);
% % % % % % fclose(fid);
% % % % % % 
% % % % % % 
% % % % % % 
% % % % % % 
