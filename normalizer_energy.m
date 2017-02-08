function [beamform_norm,meta] = normalizer_energy(mf,norm_param)
% Energy normalizer
% re. Fialkawski & Gauss 2010, IEEE JOE & Abraham & Willet 2002, IEEE JOE
%
% INPUT
%   mf      struct loaded from beamformed results
%           can be either original or subset
%   norm_param.sm_len         length of smoother; default=1
%
% OUTPUT
%   beamform_norm   normalized output
%
% Wu-Jung Lee | leewujung@gmail.com
% 2016/06/28
% 2017/02/08  revise to work with new data format
%             make it a function

if ~isfield(norm_param,'sm_len')
    norm_param.sm_len = 100;
end

% Get non-pulse compressed data
seg_fft_beam_mf_pad = fft(mf.data.beam_mf_in_time);
seg_len = size(seg_fft_beam_mf_pad,1);
seg_len_half = floor((seg_len+1)/2);
seg_fft_beam_mf = seg_fft_beam_mf_pad(1:seg_len_half,:);

tmp = conj(fft(mf.tx_sig.drive_voltage_source, seg_len));
tmp = tmp(1:seg_len_half);

seg_fft_beam = seg_fft_beam_mf./repmat(tmp.',1,size(seg_fft_beam_mf,2));
seg_fft_beam_pad = [seg_fft_beam;...
                    flipud(conj(seg_fft_beam(2:end,:)))];
beam_in_time = ifft(seg_fft_beam_pad);


% Get relevant quantities
mf_sq = zeros(size(mf.data.beam_mf_in_time));
mf_sq_sm = zeros(size(mf_sq));
for iB=1:size(mf.data.beam_mf_in_time,2)
    mf_sq(:,iB) = abs(hilbert(mf.data.beam_mf_in_time(:,iB))).^2;
    mf_sq_sm(:,iB) = smooth(mf_sq(:,iB),norm_param.sm_len);
end
mf_sq_sm = mf_sq_sm(1:norm_param.sm_len:end,:);

nomf_sq = abs(beam_in_time).^2;
nomf_sq_sm = nomf_sq(1:norm_param.sm_len:end,:);


% Normalization
tx_len_sec = mf.tx_sig.PL/1000;  % length of tx sig
t_len_sec = diff(mf.data.t(1:2))*norm_param.sm_len;  % step size for t_win in [sec]
tx_len_pt = round(tx_len_sec/t_len_sec);

want_idx = 1:size(mf_sq_sm)-tx_len_pt+1;
slide_win_idx = 0:tx_len_pt-1;

beamform_norm = zeros(size(mf_sq_sm));
for iS=want_idx
    coh_fac = mf_sq_sm(iS,:);
    incoh_fac = sum(nomf_sq_sm(iS+slide_win_idx,:),1);
    beamform_norm(iS,:) = sqrt(coh_fac./incoh_fac);
end


% Param for plotting
[amesh,rmesh] = meshgrid(mf.data.polar_angle,...
                         mf.data.range_beam(1:norm_param.sm_len:end));
[X,Y] = pol2cart(amesh/180*pi,rmesh);

% Output metadata
meta.X = X;
meta.Y = Y;
meta.mf_sq_sm = mf_sq_sm;



