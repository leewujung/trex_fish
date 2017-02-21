% 2017 02 15  Plot variation of total energy within boundary
%             Use output from echo_info

function plot_total_energy_fcn(run_num,ping_all)

%clear

if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Select run and ping range
data_path = sprintf('echo_info_run%03d',run_num);
%data_path = 'echo_info_run103';
ping_all = 3:5:911;

% Set up various paths
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Get results
energy_in_bnd = nan(length(ping_all),1);
si_W1 = nan(length(ping_all),1);
si_W2 = nan(length(ping_all),1);
max_W1 = nan(length(ping_all),1);
max_W2 = nan(length(ping_all),1);
ping_time = nan(length(ping_all),1);
for iP=1:length(ping_all)

    % Load file and set filename
    ping_num = ping_all(iP);
    scat_fname = sprintf('%s_ping%04d.mat',data_path,ping_num);

    %disp(['Processing ',scat_fname])
    S = load(fullfile(base_data_path,data_path,scat_fname));
    
    energy_in_bnd(iP) = S.energy_in_bnd;
    si_W1(iP) = S.stat_wr.scint;
    si_W2(iP) = S.stat_no.scint;
    max_W1(iP) = max(S.env_wr(:));
    max_W2(iP) = max(S.env_no(:));
    ping_time(iP) = S.time_hh;
end

% Adjust time after midnight
ping_time(ping_time<12)=ping_time(ping_time<12)+24;

% Get plotting ranges
energy_in_bnd_log = 10*log10(energy_in_bnd);
max_W1_log = 10*log10(max_W1);
max_W2_log = 10*log10(max_W2);
yrange_e = [floor(min(energy_in_bnd_log)/5)*5,...
            ceil(max(energy_in_bnd_log)/5)*5];
yrange_w = [floor(min([max_W1_log;max_W2_log])/5)*5,...
            ceil(max([max_W1_log;max_W2_log])/5)*5];
yrange_s = [0 30];


figure
subplot(311)
plot(ping_time,energy_in_bnd_log);
title('Total energy')
ylim(yrange_e)
set(gca,'xtick',16:2:32,'xticklabel',num2str([16:2:22,0:2:8]'),...
        'ytick',yrange_e(1):5:yrange_e(2))
grid

subplot(312)
plot(ping_time,max_W1_log);
hold on
plot(ping_time,max_W2_log);
title('Max echo level');
ylim(yrange_w)
set(gca,'xtick',16:2:32,'xticklabel',num2str([16:2:22,0:2:8]'),...
        'ytick',yrange_w(1):5:yrange_w(2))
grid

subplot(313)
plot(ping_time,si_W1);
hold on
plot(ping_time,si_W2);
title('Scintillation index')
ylim([0 20])
set(gca,'xtick',16:2:32,'xticklabel',num2str([16:2:22,0:2:8]'),...
        'ytick',[0,1,5:5:20])
grid


