function [rr,aa] = fit_pie(x,y)
% Find range of angle and range (distance from source) that cover the
% specified [x,y] polygon

[angle,r] = cart2pol(x,y);
rr = [min(r),max(r)];
aa = [min(angle),max(angle)];

