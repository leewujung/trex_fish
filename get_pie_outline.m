function [pie_x,pie_y,angle_want] = get_pie_outline(aa,rr)

angle_want = ceil(aa(1)/pi*180*10)/10:0.1:floor(aa(2)/pi*180*10)/10;
[pie_x,pie_y] = pol2cart([angle_want,fliplr(angle_want),angle_want(1)]/180*pi,...
    [rr(1)*ones(1,length(angle_want)),rr(2)*ones(1,length(angle_want)),rr(1)]);
