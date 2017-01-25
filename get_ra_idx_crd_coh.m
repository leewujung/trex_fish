function [range_idx,angle_idx] =...
    get_ra_idx_crd_coh(range_data,angle_data,range_want,angle_want)
% Get index of a selected range and angle extent
% for coherent cardioid beamformed data

[~,angle_idx(1)] = min(abs(angle_data-angle_want(1)));
[~,angle_idx(2)] = min(abs(angle_data-angle_want(end)));
angle_idx = sort(angle_idx);

[~,range_idx(1)] = min(abs(range_data-range_want(1)));
[~,range_idx(2)] = min(abs(range_data-range_want(end)));
