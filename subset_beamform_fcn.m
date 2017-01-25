% 2016 10 04  Retrieve only a subset of beamformed data for detailed analysis
%             Modify from 'bf_lin_coh_data_subset.m'
% 2017 01 23  Clean up code to work with new beamforming output


function subset_beamform_fcn(data_path,ping_num,base_save_path,base_data_path)
% Extract and save a subset of beamformed data for faster access
% 
% INPUT
%   data_path        path to the folder containing beamformed files
%   ping_num         ping number to be extracted,
%                    or [] for all files in the folder
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
if isempty(ping_num)
    data_files = dir(fullfile(base_data_path,data_path,'*.mat'));
    ping_len = length(data_files);
else
    ping_len = length(ping_num);
end

% Set extraction area
cut_x = [-1 -6];
cut_y = [-1 -6];
[all_rr,all_aa] = fit_pie(cut_x([1,2,2,1,1]),cut_y([2,2,1,1,2]));

B.extract_param.xlim = cut_x;
B.extract_param.ylim = cut_y;
B.extract_param.range_lim = all_rr;
B.extract_param.angle_lim = all_aa;

% Loop through all files
for iP=1:ping_len

    if isempty(ping_num)  % if processing all files in the folder
        fname = data_files(iP).name;
        scat_ping = str2double(fname(end-7:end-4));
    else
        fname = sprintf('beamform_%s_%s_run%03d_ping%04d.mat',...
                        bf_type,coh_type,run_num,ping_num(iP));
        scat_ping = ping_num(iP);
    end
    disp(['Processing ',fname]);
    A = load(fullfile(base_data_path,data_path,fname));

    save_fname = sprintf('%s_%s_%s_run%03d_ping%04d',...
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

    % Plot to check
    if 0
        env = nan(size(A.data.beam_mf_in_time));
        env_sm = nan(size(env));
        for iA=1:size(env,2)
            env(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
            env_sm(:,iA) = smooth(env(:,iA),sm_len);
        end
        env_sm = env_sm(1:sm_len:end,:);

        A.data.range_beam_sm = A.data.range_beam(1:sm_len:end);
        [amesh,rmesh] = meshgrid(A.data.polar_angle,A.data.range_beam_sm);
        [X,Y] = pol2cart(amesh/180*pi,rmesh);

        Benv = nan(size(B.data.beam_mf_in_time));
        Benv_sm = nan(size(Benv));
        for iA=1:size(Benv,2)
            Benv(:,iA) = abs(hilbert(B.data.beam_mf_in_time(:,iA)));
            Benv_sm(:,iA) = smooth(Benv(:,iA),sm_len);
        end
        Benv_sm = Benv_sm(1:sm_len:end,:);

        B.data.range_beam_sm = B.data.range_beam(1:sm_len:end);
        [Bamesh,Brmesh] = meshgrid(B.data.polar_angle,B.data.range_beam_sm);
        [BX,BY] = pol2cart(Bamesh/180*pi,Brmesh);
    end

    % Save data
    save(fullfile(save_path,[save_fname,'.mat']),'-struct','B');
    
end
