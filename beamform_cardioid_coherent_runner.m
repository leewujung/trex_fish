% 2018 05 14  Make a runner script to set up directories to do
%             coherent cardioid beamforming for TREX data

addpath('~/code_matlab_dn/');
addpath(['~/code_git/trex_fish/Triplet_processing_toolbox']);
base_save_path = '~/internal_2tb/trex/figs_results/';
base_data_path = '/media/trex_drive/TREX13_Reverberation_Package/TREX_FORA_DATA/';

% Processing for run 130
%beamform_angle = [-177:-3 3:177];   % defined from endfire angle--for cardioid bf
%run_num = 130;
%ping_num = 1:170;

%beamform_cardioid_coherent_fcn(beamform_angle,run_num,ping_num,base_save_path,base_data_path);


% Processing for run 129
beamform_angle = [-177:-3 3:177];   % defined from endfire angle--for cardioid bf
run_num = 129;
ping_num = 1:210;

beamform_cardioid_coherent_fcn(beamform_angle,run_num,ping_num,base_save_path,base_data_path);
