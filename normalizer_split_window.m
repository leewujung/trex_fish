function [beamform_norm,meta,fig] = normalizer_split_window(mf,norm_param,plot_opt)
% Split-window normalizer
% re. Fialkawski & Gauss 2010, IEEE JOE & Abraham & Willet 2002, IEEE JOE
%
% INPUT
%   mf      struct loaded from beamformed results
%           can be either original or subset
%   norm_param.sm_len         length of smoother; default=1
%   norm_param.aux_m          length of auxiliary band in [m]
%   norm_param.guard_num_bw   number of 1/bandwidth for guard band width
%   plot_opt    whether to plot comparison of smoothed and raw version
%
% OUTPUT
%   beamform_norm   normalized output
%   meta.X          X for plotting
%   meta.Y          Y for plotting
%   meta.mf_sq_sm   smoothed squared matched filter output
%
% Wu-Jung Lee | leewujung@gmail.com
% 2016/06/28
% 2017/02/06  revise to work with new data format
%             make it a function

if ~isfield(norm_param,'sm_len')
    norm_param.sm_len = 100;
end
if ~isfield(norm_param,'aux_m')
    norm_param.aux_m = 200;  % range for auxilliary band [m]
end
if ~isfield(norm_param,'guard_num_bw')
    norm_param.guard_num_bw = 2;  % number of 1/BW for guard band
end

% Get mf output magnitude squared
mf_sq = zeros(size(mf.data.beam_mf_in_time));
mf_sq_sm = zeros(size(mf.data.beam_mf_in_time));
for iB = 1:size(mf.data.beam_mf_in_time,2)
    mf_sq(:,iB) = abs(hilbert(mf.data.beam_mf_in_time(:,iB))).^2;
    mf_sq_sm(:,iB) = smooth(mf_sq(:,iB),norm_param.sm_len);
end
mf_sq_sm = mf_sq_sm(1:norm_param.sm_len:end,:);

[beamform_norm,meta] = normalizer(mf,norm_param,mf_sq,1);
[beamform_norm_sm,meta_sm] = normalizer(mf,norm_param,mf_sq_sm,norm_param.sm_len);

if plot_opt
    % Smooth normalized output
    beamform_norm_smout = zeros(size(beamform_norm));
    for iB = 1:size(beamform_norm,2)
        beamform_norm_smout(:,iB) = smooth(beamform_norm(:,iB),norm_param.sm_len);
    end
    
    fig = figure('position',[300,60,1120,930]);
    for iS=1:4
        subplot(2,2,iS)
        switch iS
            case 1  % normalize without smoothing, plot without smoothing
                h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
                title_text = 'Norm raw, plot raw';
            case 2  % normalize without smoothing, plot all points after smoothing
                h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm_smout));
                title_text = 'Norm raw, plot sm';
            case 3  % normalize without smoothing, plot jump points after smoothing
                h_norm = pcolor(meta.X(1:norm_param.sm_len:end,:)/1e3,...
                    meta.Y(1:norm_param.sm_len:end,:)/1e3,...
                    10*log10(beamform_norm_smout((1:norm_param.sm_len:end),:)));
                title_text = 'Norm raw, plot jump sm';
            case 4  % normalize with smoothing, plot as is
                h_norm = pcolor(meta_sm.X/1e3,meta_sm.Y/1e3,10*log10(beamform_norm_sm));
                title_text = 'Norm sm, plot sm';
        end
        set(h_norm,'edgecolor','none');
        axis equal
        tt = title(title_text); set(tt,'fontsize',4);
        axis([-4.3 -1.3 -4.5 -1.5])
        colormap(brewermap([],'Greys'))
        caxis([5 25]); colorbar;
        set(gca,'layer','top','fontsize',12)
    end
else
    fig = [];
end

function [beamform_norm,meta] = normalizer(mf,norm_param,mf_sq_tmp,sm_len_tmp)
% Get idx
r_len_m = diff(mf.data.range_beam(1:2))*sm_len_tmp;  % step size for r_win in [m]
t_len_sec = diff(mf.data.t(1:2))*sm_len_tmp;  % step size for t_win in [sec]
aux_pt = floor(norm_param.aux_m/r_len_m);
guard_pt = ceil(norm_param.guard_num_bw*mf.tx_sig.tau/t_len_sec);

trim = guard_pt+aux_pt;  % [pt];
aux_idx = [-trim+(0:aux_pt-1),guard_pt+1:trim];

% Normalization
want_idx = trim+1:size(mf_sq_tmp,1)-trim;
beamform_norm = zeros(size(mf_sq_tmp));
parfor iS=want_idx
    norm_fac = mean(mf_sq_tmp(iS+aux_idx,:),1);
    beamform_norm(iS,:) = mf_sq_tmp(iS,:)./norm_fac;
end

% Param for plotting
[amesh,rmesh] = meshgrid(mf.data.polar_angle,...
                         mf.data.range_beam(1:sm_len_tmp:end));
[X,Y] = pol2cart(amesh/180*pi,rmesh);

% Output metadata
meta.X = X;
meta.Y = Y;



