function [x,dens,bw] = findEchoDist_kde(s,npt)
% INPUT
%   s      samples
%   npt    number of points for echo pdf
% OUTPUT
%   dens   estimated density
%   x      x-axis of estimated density
%   bw     bandwidth of the kernel
%
% 2012 09 25  Use kernel density estimation to find echo pdf
%             Use Botev's kde method (Botev et al., 2010)
% 2017 02 27  Fixed x-axis bin location

% transform data into log10 space
[bw,dens_log,x_log] = kde(log10(s),npt,0);
%[dens_log,x_log,bw]=ksdensity(log10(s));
%x_log = x_log';
x_log = sqrt(x_log(1:end-1).*x_log(2:end));
x = 10.^x_log.';   % transform back, adjust dimension as well
slope = 1./x;      % scale the estimated density back according
                   % to corresponding bandwidth on linear scale
scale = trapz(x,dens_log(1:end-1).*slope);  % rescale in the linear domain
dens = dens_log(1:end-1).*slope./scale;

%-----Below is old code that didn't shift the x-axis location correctly-----
%x = 10.^x_log.';   % transform back, adjust dimension as well
%slope = 1./x;      % scale the estimated density back according
%                   % to corresponding bandwidth on linear scale
%scale = trapz(x,dens_log.*slope);  % rescale in the linear domain
%dens = dens_log.*slope./scale;
