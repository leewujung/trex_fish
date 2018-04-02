% 2016 08 29  Beampattern prediction comparsion: MF and single freq
% 2018 04 01  Use element coordination from beamform/compiled data
%             directly for clarity

clear
if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
end

% Set data file and save folder
run_num = 131;
data_path = sprintf('subset_beamform_cardioid_coherent_run%03d',run_num);

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path, ...
    sprintf('%s_run%d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

scat_ping = 1;
fname = sprintf('%s_ping%04d.mat',data_path,scat_ping);
A = load(fullfile(base_data_path,data_path,fname));

% Beamform param
th = -87:0.1:87;  % defined from broadside
th = th/180*pi;
freq = [1.8:0.1:3.6]*1e3;
cw = 1525;  % sound speed
k = 2*pi*freq/cw;

array_coord_mean = mean(A.param.array_coord,1);
dY = A.param.array_coord(:,2)-array_coord_mean(2);

phase_delay = zeros(length(freq),length(dY),length(th));
beam = zeros(length(freq),length(th));
for iF=1:length(freq)
    phase_delay(iF,:,:) = exp(1j*dY*sin(th)*k(iF));
    beam(iF,:) = sum(squeeze(phase_delay(iF,:,:)),1);
end
beam_log_norm = 20*log10(abs(beam))-repmat(max(20*log10(abs(beam)),[],2),1,length(th));
beam_mf_coh_LF = abs(sum(beam(1:10,:),1).^2);
beam_mf_incoh_LF = sum(abs(beam(1:10,:)).^2,1);
beam_mf_coh_HF = abs(sum(beam(10:end,:),1).^2);
beam_mf_incoh_HF = sum(abs(beam(10:end,:)).^2,1);
beam_mf_coh_All = abs(sum(beam,1).^2);
beam_mf_incoh_All = sum(abs(beam).^2,1);

figure
h = plot(th/pi*180,beam_log_norm,'color',[1 1 1]*170/255);
hold on
h3600 = plot(th/pi*180,beam_log_norm(end,:),'k','linewidth',1);
hmf_incoh_LF = plot(th/pi*180,10*log10(beam_mf_incoh_LF)-max(10*log10(beam_mf_incoh_LF)),'b','linewidth',1);
hmf_coh_LF = plot(th/pi*180,10*log10(beam_mf_coh_LF)-max(10*log10(beam_mf_coh_LF)),'r','linewidth',1);
hmf_incoh_HF = plot(th/pi*180,10*log10(beam_mf_incoh_HF)-max(10*log10(beam_mf_incoh_HF)),'b--','linewidth',1);
hmf_coh_HF = plot(th/pi*180,10*log10(beam_mf_coh_HF)-max(10*log10(beam_mf_coh_HF)),'r--','linewidth',1);
legend([h(1),h3600,hmf_coh_LF,hmf_incoh_LF,hmf_coh_HF,hmf_incoh_HF],...
       '1.8:0.1:3.6 kHz','3.6 kHz',...
       '1.8-2.7 kHz coherent','1.8-2.7 kHz incoherent',...
       '2.7-3.6 kHz coherent','2.7-3.6 kHz incoherent');
xlim([-20 20])
ylim([-30 3])
grid
xlabel('Beam angle (deg)');
ylabel('Normalized beampattern');

saveas(gcf,fullfile(save_path,[script_name,'.fig']),'fig');
saveSameSize_150(gcf,'file',fullfile(save_path,[script_name,'.png']),...
    'format','png','renderer','painters');

xlim([-3 3])
ylim([-4 1])
set(gca,'xtick',-3:0.5:3);
saveas(gcf,fullfile(save_path,[script_name,'_zoom.fig']),'fig');
saveSameSize_150(gcf,'file',fullfile(save_path,[script_name,'_zoom.png']),...
    'format','png','renderer','painters');
