% 2016/06/28  Energy normalizer
%             re. Fialkawski & Gauss 2010, IEEE JOE
% 2017/02/08  Revise to work with new beamformed data format


data_path=['/media/wu-jung/wjlee_apl_1/trex_results/' ...
           'beamform_linear_coherent_run131']
data_file = 'beamform_linear_coherent_run131_ping0150.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


sm_len = 100;
mf_sq = zeros(size(mf.data.beam_mf_in_time));
mf_sq_sm = zeros(size(mf_sq));
for iB=1:size(mf.data.beam_mf_in_time,2)
    mf_sq(:,iB) = abs(hilbert(mf.data.beam_mf_in_time(:,iB))).^2;
    mf_sq_sm(:,iB) = smooth(mf_sq(:,iB),sm_len);
end
mf_sq_sm = mf_sq_sm(1:sm_len:end,:);

nomf_sq = abs(beam_in_time).^2;
nomf_sq_sm = nomf_sq(1:sm_len:end,:);

tx_len_sec = mf.tx_sig.PL/1000;  % length of tx sig
t_len_sec = diff(mf.data.t(1:2))*sm_len;  % step size for t_win in [sec]
tx_len_pt = round(tx_len_sec/t_len_sec);

want_idx = 1:size(mf_sq_sm)-tx_len_pt+1;
slide_win_idx = 0:tx_len_pt-1;

mf_sq_sm_norm = zeros(size(mf_sq_sm));
for iS=want_idx
    coh_fac = mf_sq_sm(iS,:);
    incoh_fac = sum(nomf_sq_sm(iS+slide_win_idx,:),1);
    mf_sq_sm_norm(iS,:) = sqrt(coh_fac./incoh_fac);
end




