function h = plot_normalized_echogram(h,beamform_norm,meta,norm_caxis,axis_lim)
% Plot output from normalizer_split_window:
% [beamform_norm,meta] = normalizer_split_window(A,norm_param);

axes(h)
h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
hold on
set(h_norm,'edgecolor','none');
axis equal
colormap(jet)
caxis(norm_caxis)
axis(axis_lim)
xlabel('Distance (km)','fontsize',14)
ylabel('Distance (km)','fontsize',14)
set(gca,'fontsize',12)
