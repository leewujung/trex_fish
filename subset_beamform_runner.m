% 2018 05 15  Make a runner script to extract and save a subset of
%             beamformed data for faster access 


addpath('~/code_matlab_dn/');
addpath(['~/code_git/trex_fish/Triplet_processing_toolbox']);
base_save_path = '~/internal_2tb/trex/figs_results/';
base_data_path = '~/internal_2tb/trex/figs_results/';

% Processing for run 130
%data_path = 'beamform_cardioid_coherent_run130';
%ping_num = 1:170;
%subset_beamform_fcn(data_path,ping_num,base_save_path,base_data_path);

% Processing for run 129
data_path = 'beamform_cardioid_coherent_run129';
ping_num = 1:210;
subset_beamform_fcn(data_path,ping_num,base_save_path,base_data_path);

