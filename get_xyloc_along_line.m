function [I,xy_loc,r_loc] = get_xyloc_along_line(A,sm_len,xy,wr_ctr)
% INPUT
%   A        beamformed results
%   sm_len   length of smoothing for plotting
%   xy       x-y positions of points wanted [km]
%   wr_ctr   x-y position of the center of wreck [km]
% OUTPUT
%   xy_loc   locations from which the echo levels are extracted from
%   r_loc    radial range from center of wreck
%
% Wu-Jung Lee | leewujung@gmail.com


% Get plotting params
A.data.range_beam_sm = A.data.range_beam(1:sm_len:end);
[amesh,rmesh] = meshgrid(A.data.polar_angle,A.data.range_beam_sm);
[X,Y] = pol2cart(amesh/180*pi,rmesh);
X = X(:);
Y = Y(:);

% Find closest index
[D,I] = pdist2([X,Y]/1e3,xy,'euclidean','SMALLEST',1);

keyboard
ii = sort(abs(diff(I)),'descend');
I = I(abs(diff(I))>mean(ii(1:5))/4);

% Output
xy_loc = [X(I),Y(I)];
r_loc = pdist2(wr_ctr,xy_loc/1e3,'euclidean');

