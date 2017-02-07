function [beamform_norm,meta] = normalizer_split_window(mf,norm_param)
% Split-window normalizer
% re. Fialkawski & Gauss 2010, IEEE JOE & Abraham & Willet 2002, IEEE JOE
%
% INPUT
%   mf      struct loaded from beamformed results
%           can be either original or subset
%   norm_param.sm_len         length of smoother; default=1
%   norm_param.aux_m          length of auxiliary band in [m]
%   norm_param.guard_num_bw   number of 1/bandwidth for guard band width
%
% OUTPUT
%   beamform_norm   normalized output
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

% Get idx
r_len_m = diff(mf.data.range_beam(1:2))*norm_param.sm_len;  % step size for r_win in [m]
t_len_sec = diff(mf.data.t(1:2))*norm_param.sm_len;  % step size for t_win in [sec]

aux_pt = floor(norm_param.aux_m/r_len_m);
guard_pt = ceil(norm_param.guard_num_bw*mf.tx_sig.tau/t_len_sec);

slide_win_pt = 1+2*guard_pt+2*aux_pt;  % [pt]
trim = guard_pt+aux_pt;  % [pt];
slide_idx = -trim:trim;
aux_idx = [-trim+(0:aux_pt-1),guard_pt+1:trim];

% Get mf output magnitude squared
mf_sq = zeros(size(mf.data.beam_mf_in_time));
mf_sq_sm = zeros(size(mf.data.beam_mf_in_time));
for iB = 1:size(mf.data.beam_mf_in_time,2)
    mf_sq(:,iB) = abs(hilbert(mf.data.beam_mf_in_time(:,iB))).^2;
    mf_sq_sm(:,iB) = smooth(mf_sq(:,iB),norm_param.sm_len);
end
mf_sq_sm = mf_sq_sm(1:norm_param.sm_len:end,:);

% Normalization
want_idx = trim+1:size(mf_sq_sm,1)-trim;
beamform_norm = zeros(size(mf_sq_sm));
for iS=want_idx
    norm_fac = mean(mf_sq_sm(iS+aux_idx,:),1);
    beamform_norm(iS,:) = mf_sq_sm(iS,:)./norm_fac;
end

% Param for plotting
[amesh,rmesh] = meshgrid(mf.data.polar_angle,...
                         mf.data.range_beam(1:norm_param.sm_len:end));
[X,Y] = pol2cart(amesh/180*pi,rmesh);

% Output metadata
meta.X = X;
meta.Y = Y;
meta.mf_sq_sm = mf_sq_sm;



