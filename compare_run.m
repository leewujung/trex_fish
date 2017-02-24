% 2017 02 20  Compare trend from all runs

if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/brewermap');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Set up various paths
[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Set up params
% note: not including run103 due to oscillating echo levels
%       not including run120 since it doesn't include dusk nor dawn
run_num_all = [79,87,94,115,124,131];
ping_num{1} = 4:9:877;    % run 79
ping_num{2} = 1:1:1000;   % run 87
ping_num{3} = 3:3:899;    % run 94
ping_num{4} = 2:2:926;    % run 115
ping_num{5} = 2:2:973;    % run 124
ping_num{6} = 2:2:1000;   % run 131
dates{1} = 'May 9';
dates{2} = 'May 10';
dates{3} = 'May 11';
dates{4} = 'May 13';
dates{5} = 'May 15';
dates{6} = 'May 16';

%      summarize_run_fcn(run_num, ping_all, wfm_num, plot_opt)
A(1) = summarize_run_fcn(run_num_all(1),ping_num{1},ping_num{1}(1),0);
for iR=2:length(run_num_all)
    A(iR) = summarize_run_fcn(run_num_all(iR),ping_num{iR},ping_num{iR}(1),0);
end  


% Set plotting params
time_start = 19;
time_end = 30;
time = time_start:0.01:time_end;
cmap_num = brewermap(length(run_num_all)+2,'Blues');
set(0,'DefaultAxesColorOrder',cmap_num(3:end,:))

% Compare all
sm_len=10;
fig_cmp = figure('position',[675 110 810 880]);
for iR=1:length(run_num_all)
    ping_idx = find(A(iR).ping_time>=time_start & A(iR).ping_time<=time_end);
    if iR==3  % make normalized output look better
              % since first ping is much higher than the rest
        ping_idx(1) = [];
    end
    ping_time = A(iR).ping_time(ping_idx);
    max_W1 = 10*log10(A(iR).max_W1(ping_idx));
    max_W2 = 10*log10(A(iR).max_W2(ping_idx));
    E = 10*log10(A(iR).energy_in_bnd(ping_idx));
    if sm_len~=1
        if iR~=1
            max_W1 = smooth(max_W1,sm_len);
            max_W2 = smooth(max_W2,sm_len);
            E = smooth(E,sm_len);
        else
            max_W1 = smooth(max_W1,3);
            max_W2 = smooth(max_W2,3);
            E = smooth(E,3);
        end
    end
    max_W1_norm = max_W1-max(max_W1);
    max_W2_norm = max_W2-max(max_W2);
    E_norm = E-max(E);

    subplot(311)
    plot(ping_time,max_W1_norm,'linewidth',1);
    hold on
    subplot(312)
    plot(ping_time,max_W2_norm,'linewidth',1);
    hold on
    subplot(313)
    plot(ping_time,E_norm,'linewidth',1);
    hold on
end
subplot(311)
legend(dates,'location','EastOutside')
xlabel('Hour')
ylabel('Normalized echo level (dB)')
title('E_{max} W1')
axis([19 30 -10 1])
grid on
set(gca,'xtick',19:30,'xticklabel',{num2str([18:23,0:6]')})
set(gca,'layer','top')

subplot(312)
legend(dates,'location','EastOutside')
xlabel('Hour')
ylabel('Normalized echo level (dB)')
title('E_{max} W2')
axis([19 30 -10 1])
grid on
set(gca,'xtick',19:30,'xticklabel',{num2str([18:23,0:6]')})
set(gca,'layer','top')

subplot(313)
legend(dates,'location','EastOutside')
xlabel('Hour')
ylabel('Normalized echo level (dB)')
title('Total energy in boundary')
axis([19 30 -10 1])
grid on
set(gca,'xtick',19:30,'xticklabel',{num2str([18:23,0:6]')})
set(gca,'layer','top')

saveas(gcf,fullfile(save_path,[script_name,'.fig']));
saveSameSize_150(gcf,'file',fullfile(save_path,[script_name,'.png']),...
                 'format','png');

