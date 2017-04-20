function h = plot_normalized_echogram(h,beamform_norm,meta,norm_param,norm_caxis,axis_lim)
% Plot output from normalizer_split_window:
% [beamform_norm,meta] = normalizer_split_window(A,norm_param);

% Smooth normalized output
beamform_norm_smout = zeros(size(beamform_norm));
for iB = 1:size(beamform_norm,2)
    beamform_norm_smout(:,iB) = smooth(beamform_norm(:,iB),norm_param.sm_len);
end

axes(h)
h_norm = pcolor(meta.X(1:norm_param.sm_len:end,:)/1e3,...
    meta.Y(1:norm_param.sm_len:end,:)/1e3,...
    10*log10(beamform_norm_smout((1:norm_param.sm_len:end),:)));
hold on
set(h_norm,'edgecolor','none');
axis equal
colormap(jet)
caxis(norm_caxis)
axis(axis_lim)
xlabel('Distance (km)','fontsize',14)
ylabel('Distance (km)','fontsize',14)
set(gca,'fontsize',12)
