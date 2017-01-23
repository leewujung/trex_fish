% 2016 10 04  Retrieve only a subset of beamformed data for detailed analysis
%             Modify from 'bf_lin_coh_data_subset.m'
% 2017 01 23  Clean up code to work with new beamforming output


function subset_beamform_fcn(data_path,base_save_path,base_data_path)
% Extract and save a subset of beamformed data for faster access
% 
% INPUT
%   data_path        path to the folder containing beamformed files
%   base_data_path   path to the base results folder
%   base_save_path   path to the base folder where extracted results are saved
%
% Wu-Jung Lee | leewujung@gmail.com
% 2017 01 23

% Set up various paths
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));
bf_type = ss{2};
coh_type = ss{3};

[~,script_name,~] = fileparts(mfilename('fullpath'));
script_name = script_name(1:end-4);
save_path = fullfile(base_save_path,...
            sprintf('%s_%s_%s_run%03d',script_name,bf_type,coh_type,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Ping range
data_files = dir(fullfile(base_data_path,data_path,'*.mat'));

% Set extraction area
cut_x = [-1 -6];
cut_y = [-1 -6];
[all_rr,all_aa] = fit_pie(cut_x([1,2,2,1,1]),cut_y([2,2,1,1,2]));

B.extract_param.xlim = cut_x;
B.extract_param.ylim = cut_y;
B.extract_param.range_lim = all_rr;
B.extract_param.angle_lim = all_aa;

% Loop through all files
for iP=1:length(data_files)
    
    fname = data_files(iP).name;
    disp(['Processing ',fname]);
    A = load(fullfile(base_data_path,data_path,fname));

    scat_ping = str2double(fname(end-7:end-4));
    save_fname = sprintf('%s_%s_%s_run%03d_p%04d',...
        script_name,bf_type,coh_type,run_num,scat_ping);
    
    B.param = A.param;  % copy all parameters
    B.extract_param.ori_filename = fname;
    
    % Get index range of angle and range
    [~,angle_idx(1)] = min(abs(A.data.polar_angle-all_aa(1)/pi*180));
    [~,angle_idx(2)] = min(abs(A.data.polar_angle-all_aa(2)/pi*180));
    angle_idx = sort(angle_idx);
    
    [~,range_idx(1)] = min(abs(A.data.range_beam/1e3-all_rr(1)));
    [~,range_idx(2)] = min(abs(A.data.range_beam/1e3-all_rr(2)));

    A.data.polar_angle = A.data.polar_angle(angle_idx(1):angle_idx(2));
    A.data.range_beam = A.data.range_beam(range_idx(1):range_idx(2));
    A.data.t = A.data.t(range_idx(1):range_idx(2));
    A.data.beam_mf_in_time = A.data.beam_mf_in_time(range_idx(1):range_idx(2),...
                                                    angle_idx(1):angle_idx(2));
    B.data = A.data;
    B.data = rmfield(B.data,'cut_idx');

    B.extract_param.angle_extract_idx = angle_idx;
    B.extract_param.range_extract_idx = range_idx;    
    B.extract_param = orderfields(B.extract_param);
    
    B.tx_sig = A.tx_sig;

    % Save data
    save(fullfile(save_path,[save_fname,'.mat']),'-struct','B');
    
end
