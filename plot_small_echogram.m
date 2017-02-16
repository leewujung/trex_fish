function h = plot_small_echogram(h,A,sm_len,color_axis,axis_lim)
% Function to plot echogram in focused area
% 
% INPUT
%   h   handle of axis to be plotted on
%   A   beamformed results
%   sm_len       length of smoothing for plotting
%   color_axis   caxis range
%   axis_lim     axis limit for figure
%
% Wu-Jung Lee | leewujung@gmail.com


% Get envelope and smooth/subsample
env = nan(size(A.data.beam_mf_in_time));
env_sm = nan(size(env));
for iA=1:size(env,2)
    env(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
    env_sm(:,iA) = smooth(env(:,iA),sm_len);
end
env_sm = env_sm(1:sm_len:end,:);

% Get plotting params
A.data.range_beam_sm = A.data.range_beam(1:sm_len:end);
[amesh,rmesh] = meshgrid(A.data.polar_angle,A.data.range_beam_sm);
[X,Y] = pol2cart(amesh/180*pi,rmesh);

% Echo level calibration
total_gain_crd_coh = A.param.gain_load -...
                     A.param.gain_sys -...
                     A.param.gain_beamform -...
                     A.param.gain_pc;

% Rough transmission loss compensation
TL_comp = repmat(30*log10(A.data.range_beam_sm)',...
                 1,size(X,2));

% Plot
axes(h)
cla
h1 = pcolor(X/1e3,Y/1e3,20*log10(env_sm)+...
            total_gain_crd_coh-3 +TL_comp);
hold on
set(h1,'edgecolor','none');
axis equal
colormap(jet)
colorbar('location','southoutside');
caxis(color_axis)
axis(axis_lim)
xlabel('Distance (km)','fontsize',14)
ylabel('Distance (km)','fontsize',14)
set(gca,'fontsize',12)
