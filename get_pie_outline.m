function [pie_x,pie_y] = get_pie_outline(aa,rr)
% Get outline of cut area specified by the desired range of angle and range
% INPUT
%   aa   desired range of angle [deg]
%   rr   desired range of range [m]

aa = sort(aa);
rr = sort(rr);

angle_want = round(aa(1)*10)/10:0.1:round(aa(2)*10)/10;
[pie_x,pie_y] = pol2cart([angle_want,fliplr(angle_want),angle_want(1)]/180*pi,...
    [rr(1)*ones(1,length(angle_want)),rr(2)*ones(1,length(angle_want)),rr(1)]);
