function [I,xy_loc,r_proj] = get_xyloc_along_line(A,sm_len,wr_ctr,dl)
% INPUT
%   A        beamformed results
%   sm_len   length of smoothing for plotting
%   xy       x-y positions of points wanted [km]
%   wr_ctr   x-y position of the center of wreck [km]
% OUTPUT
%   xy_loc   locations from which the echo levels are extracted from
%   r_proj   projected range between xy_loc and wr_ctr onto the specified direction
%
% Wu-Jung Lee | leewujung@gmail.com


% Get plotting params
A.data.range_beam_sm = A.data.range_beam(1:sm_len:end);
[amesh,rmesh] = meshgrid(A.data.polar_angle,A.data.range_beam_sm);
[X,Y] = pol2cart(amesh/180*pi,rmesh);
X = X(:);
Y = Y(:);

% Find closest index
[D,I] = pdist2([X,Y]/1e3,dl.xy_vec,'euclidean','SMALLEST',1);
I = unique(I);

% Pseudo-output
xy_loc = [X(I),Y(I)]/1e3;
r_proj = (xy_loc-repmat(wr_ctr,size(xy_loc,1),1))*dl.unit_vec';
%r_loc = pdist2(wr_ctr,xy_loc,'euclidean')';

% Output
[r_proj,ir] = sort(r_proj,'ascend');
I = I(ir);
xy_loc = xy_loc(ir,:);

