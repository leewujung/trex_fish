function echo_level = get_echo_level_along_line(A,sm_len,I,r_proj,dl)
% INPUT
%   A        beamformed results
%   sm_len   length of smoothing for plotting
%   I        total 1D of env_sm after flattened
% OUTPUT
%   echo_level   echo level along the input line
%
% Wu-Jung Lee | leewujung@gmail.com


% Get envelope and smooth/subsample
env = nan(size(A.data.beam_mf_in_time));
env_sm = nan(size(env));
for iA=1:size(env,2)
    env(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
    if sm_len==1
        env_sm(:,iA) = env(:,iA);
    else
        env_sm(:,iA) = smooth(env(:,iA),sm_len);
    end
end
env_sm = env_sm(1:sm_len:end,:);

A.data.range_beam_sm = A.data.range_beam(1:sm_len:end);


% Compensate for echo level
total_gain_crd_coh = A.param.gain_load -...
                     A.param.gain_sys -...
                     A.param.gain_beamform -...
                     A.param.gain_pc;
TL_comp = repmat(30*log10(A.data.range_beam_sm)',...
                 1,size(env_sm,2));
env_final = 20*log10(env_sm)+total_gain_crd_coh-3+TL_comp;
env_final = env_final(:);

% Get echo level through 2D interpolation
echo_level = interp1(r_proj,env_final(I),dl.r_vec,'linear','extrap');


