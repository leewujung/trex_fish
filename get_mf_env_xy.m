function [mf_env,plot_param] = get_mf_env_xy(A,sm_len)
% Getting echo envelope and x,y coordinates for plotting
% INPUT
%   A        beamformed data structure
%   sm_len   smoothing and decimation length
% OUTPUT
%   mf_env      envelope of matched filter output
%   plot_param  x,y coordinates for pcolor plotting
%
% Wu-Jung Lee | leewujung@gmail.com
% 2017 01 25  revised from old code

% getting echo envelope
env = nan(size(A.data.beam_mf_in_time));
env_sm = nan(size(env));
for iA=1:size(env,2)
    env(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
    env_sm(:,iA) = smooth(env(:,iA),sm_len);
end
env_sm = env_sm(1:sm_len:end,:);

mf_env.env = env;
mf_env.env_sm = env_sm;

% range vector
plot_param.range_beam = A.data.range_beam;
plot_param.range_beam_sm = A.data.range_beam(1:sm_len:end);

% (x,y) coord for using pcolor
[amesh,rmesh] = meshgrid(A.data.polar_angle,...
                         plot_param.range_beam);
[plot_param.X,plot_param.Y] = pol2cart(amesh/180*pi,rmesh);

[amesh_sm,rmesh_sm] = meshgrid(A.data.polar_angle,...
                               plot_param.range_beam_sm);
[plot_param.X_sm,plot_param.Y_sm] = pol2cart(amesh_sm/180*pi,rmesh_sm);

