% 2017 01 18  Compare beamforming results from all combination of methods
%             coherent vs incoherent, linear vs cardioid

clear
addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
addpath('~/internal_2tb/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox')
base_save_path = '~/internal_2tb/trex/figs_results/';
base_data_path = '~/internal_2tb/trex/figs_results/';


% Set up various paths
lin_coh_data_path   = 'beamform_linear_coherent_run131';
lin_incoh_data_path = 'beamform_linear_incoh_run131';
crd_coh_data_path   = 'beamform_cardioid_coherent_run131';
crd_incoh_data_path = 'beamform_cardioid_incoh_run131';

ss = strsplit(lin_coh_data_path,'_');
run_num = str2double(ss{end}(4:end));

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end


% Load files
ping = 150;

lin_coh_fname = sprintf('%s_ping%04d.mat',lin_coh_data_path,ping);
lin_coh = load(fullfile(base_data_path,lin_coh_data_path,lin_coh_fname));

lin_incoh_fname = sprintf('%s_ping%04d.mat',lin_incoh_data_path,ping);
lin_incoh = load(fullfile(base_data_path,lin_incoh_data_path,lin_incoh_fname));

crd_incoh_fname = sprintf('%s_ping%04d.mat',crd_incoh_data_path,ping);
crd_incoh = load(fullfile(base_data_path,crd_incoh_data_path,crd_incoh_fname));

crd_coh_fname = sprintf('%s_ping%04d.mat',crd_coh_data_path,ping);
crd_coh = load(fullfile(base_data_path,crd_coh_data_path,crd_coh_fname));


% Comparison
total_gain_crd_coh = crd_coh.param.gain_load -...
                     crd_coh.param.gain_sys -...
                     crd_coh.param.gain_beamform -...
                     crd_coh.param.gain_pc;
total_gain_lin_coh = lin_coh.param.gain_load -...
                     lin_coh.param.gain_sys -...
                     lin_coh.param.gain_beamform -...
                     lin_coh.param.gain_pc;
es_crd_coh = 20*log10(abs(hilbert(crd_coh.data.beam_mf_in_time)))-3;
es_lin_coh = 20*log10(abs(hilbert(lin_coh.data.beam_mf_in_time)))-3;

figure
corder = get(gca,'colororder');
plot(crd_incoh.data.range_beam/1e3,smooth(crd_incoh.data.beamform,50))
hold on
plot(lin_incoh.data.range_beam/1e3,smooth(lin_incoh.data.beamform,50)-3)
plot(crd_coh.data.range_beam/1e3,...
     smooth(es_crd_coh,500)+total_gain_crd_coh-1.5);
plot(lin_coh.data.range_beam/1e3,...
     smooth(es_lin_coh,500)+total_gain_lin_coh-1.5-3,...
     'color',corder(5,:));
ll = legend('Cardioid incoherent (Jie)',...
       'Linear incoherent',...
       'Cardioid coherent',...
       'Linear coherent');
set(ll,'fontsize',12);
xlabel('Range (km)');
ylabel('SPL (dB)');
title('Comparison of processing methods')
xlim([0 6])
grid



