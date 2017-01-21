% 2016 10 04  Retrieve only a subset of beamformed data for detailed analysis
%             Modify from 'bf_lin_coh_data_subset.m'

clear

if isunix
    addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath(['/home/wu-jung/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\trex_fish\Triplet_processing_toolbox')
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Set up various paths
data_path = 'beamform_cardioid_coherent_run079';
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));
bf_type = ss{2};

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

B.data_path = data_path;
B.run_num = run_num;

% Ping range
% ping_all = [1:193,];
data_files = dir(fullfile(base_data_path,data_path,'*.mat'));

% Set overall area
cut_x = [-1 -6];
cut_y = [-1 -6];
[all_rr,all_aa] = fit_pie(cut_x([1,2,2,1,1]),cut_y([2,2,1,1,2]));
[all_pie_x,all_pie_y,all_aa] = get_pie_outline(all_aa,all_rr);

B.cut_x = cut_x;
B.cut_y = cut_y;
B.all_rr = all_rr;
B.all_aa = all_aa;
B.all_pie_x = all_pie_x;
B.all_pie_y = all_pie_y;

% Set up for plotting
sm_len = 100;

if run_num>=41
    sig_gain = 12;
else
    sig_gain = 18;
end

if strcmp(bf_type,'cardioid')
    calib_gain = 46.95;
elseif strcmp(bf_type,'linear')
    calib_gain = 42.35;
end

B.sm_len = sm_len;
B.sig_gain = sig_gain;
B.calib_gain = calib_gain;

for iP=1:length(data_files)
    
%     fname = sprintf('%s_ping%04d.mat',data_path,scat_ping);
    fname = data_files(iP).name;
    disp(['Processing ',fname]);
    
    A = load(fullfile(base_data_path,data_path,fname));
    
%     scat_ping = ping_all(iP);
    scat_ping = str2double(fname(end-7:end-4));
    save_fname = sprintf('%s_run%03d_p%04d',...
        script_name,run_num,scat_ping);
    
    B.fname = fname;
    B.t = A.data.t;
    
    % Time
    time_str_scat = sprintf('%02d:%02d:%02d',A.data.time_hh_local,...
        A.data.time_mm_local,A.data.time_ss_local);
    
    B.time_str_scat = time_str_scat;
    
    % Range/angle index
    [all_a_idx,all_r_idx] = ...
        get_range_angle_idx_coh(A.data.polar_angle,A.data.range_beam,all_aa,all_rr);
    
    B.all_a_idx = all_a_idx;
    B.all_r_idx = all_r_idx;
    B.polar_angle = A.data.polar_angle(all_a_idx(1):all_a_idx(2));
    B.range_beam = A.data.range_beam(all_r_idx(1):all_r_idx(2));
    
    % Get envelope
    bf_env_scat = nan(size(A.data.beam_mf_in_time));
    bf_env_scat_sm = nan(size(A.data.beam_mf_in_time));
    for iA=1:size(A.data.beam_mf_in_time,2)
        bf_env_scat(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
        bf_env_scat_sm(:,iA) = smooth(bf_env_scat(:,iA),sm_len);
    end
    
    B.beam_mf_in_time = A.data.beam_mf_in_time(all_r_idx(1):all_r_idx(2),all_a_idx(1):all_a_idx(2));
    
    % Condition data
    norm_fac_fft = -10*log10(size(bf_env_scat_sm,1));  % fft scatling
    norm_fac_gain = calib_gain - sig_gain;              % gain, re foracal.pdf from Jie
    
    B.norm_fac_fft = norm_fac_fft;
    B.norm_fac_gain = norm_fac_gain;
    
    % Save data
    save(fullfile(save_path,[save_fname,'.mat']),'-struct','B');
    
end
