% 2017 02 24  Time series of Emax, total energy, SI, with sunrise/sunset info
%             for run131

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
run_num = 131;
wfm = 2;
ping_num = wfm:2:1000;   % run 131
dates = 'May 16';

% Load data
A = summarize_run_fcn(run_num,ping_num,ping_num(1),0);
B = load(fullfile(base_data_path,...
                  ['subset_beamform_cardioid_coherent_run131/' ...
                   'subset_beamform_cardioid_coherent_run131_ping0100.mat']));

% Set plotting params
time_start = 19;
time_end = 30;
time = time_start:0.01:time_end;
sunset = 20+28/60;    % nautical twilight end
sunrise = 4+49/60+24; % nautical twilight start

% Get energy measures
ping = 1:length(A.ping_time);
ping_idx = find(A.ping_time>=time_start & A.ping_time<=time_end);
ping_time = A.ping_time(ping_idx);
max_W1 = 20*log10(A.max_W1(ping_idx));
max_W2 = 20*log10(A.max_W2(ping_idx));
E = 10*log10(A.energy_in_bnd(ping_idx));
si_W1 = A.si_W1(ping_idx);
si_W2 = A.si_W2(ping_idx);

% Apply cal values
total_gain_crd_coh = B.param.gain_load -...
                     B.param.gain_sys -...
                     B.param.gain_beamform -...
                     B.param.gain_pc;
max_W1_cal = max_W1+total_gain_crd_coh-3;  % compensate for gain and hilbert
max_W2_cal = max_W2+total_gain_crd_coh-3;
E_cal = E+total_gain_crd_coh-3;
E_cal = 10*log10(10.^(E_cal/20)/B.data.sample_freq);

% Get sun phase sine
f = 1/(sunrise-sunset)/2;
sun_sine = -sin(2*pi*f*(time-sunset));
[~,idx_sunset] = min(abs(time-sunset));
[~,idx_sunrise] = min(abs(time-sunrise));

% Plot
fig_cmp = figure('position',[675 110 600 880]);
corder = get(gca,'colororder');

set(gca,'position',[.13 .94 .8 .02]);
area(time(1:idx_sunset),ones(1,idx_sunset),'facecolor','white','edgecolor','none')
hold on
area(time(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1),...
     'facecolor','k','edgecolor','none')
area(time(idx_sunrise:end),ones(1,length(time)-idx_sunrise+1),...
     'facecolor','white','edgecolor','none')
set(gca,'ytick',[],'xlim',[19 30],'xtick',19:30,'xticklabel','')
title(sprintf('Wfm %d',wfm))

sub2 = axes;
set(sub2,'position',[.13 .68 .8 .22])
hw1 = plot(ping_time,max_W1_cal,'color',corder(1,:),'linewidth',0.5,'linestyle','-');
hold on
hw2 = plot(ping_time,max_W2_cal,'color',corder(2,:),'linewidth',0.5);
hv1 = plot(time(idx_sunset)*[1 1],[75 115],'color',[1 1 1]*170/255,'linewidth',1);
hv2 = plot(time(idx_sunrise)*[1 1],[75 115],'color',[1 1 1]*170/255,'linewidth',1);
axis([19 30 75 115])
grid
ylabel('SPL (dB re 1 \muPa)')
set(gca,'xtick',19:30,'xticklabel','')
ll = legend('W1','W2','location','south');
set(ll,'fontsize',12)
title('Emax')

sub3 = axes;
set(sub3,'position',[.13 .42 .8 .22])
he = plot(ping_time,E_cal,'linewidth',0.5,'color','k');
hold on
hv1 = plot(time(idx_sunset)*[1 1],[19 27],'color',[1 1 1]*170/255,'linewidth',1);
hv2 = plot(time(idx_sunrise)*[1 1],[19 27],'color',[1 1 1]*170/255,'linewidth',1);
if wfm==1
    axis([19 30 19 28])
else
    axis([19 30 19 27])
end
grid
ylabel('Energy (dB re 1 \muPa^2-s)')
set(gca,'xtick',19:30,'xticklabel','')
title('Total energy')

sub4 = axes;
set(sub4,'position',[.13 .16 .8 .22])
hsi = plot(ping_time,si_W2,'linewidth',0.5,'color','k');
hold on
hv1 = plot(time(idx_sunset)*[1 1],[0 10],'color',[1 1 1]*170/255,'linewidth',1);
hv2 = plot(time(idx_sunrise)*[1 1],[0 10],'color',[1 1 1]*170/255,'linewidth',1);
xlabel('Hour of day')
ylabel('SI');
set(gca,'xtick',19:30,'xticklabel',{num2str([19:23,0:7]')})
axis([19 30 0 10])
title('Scintillation index')
grid

subx = axes;
set(subx,'Position',[.13 .09 .8 1e-12]);
set(subx,'xlim',[0 440],'xtick',0:40:440)
xlabel('Ping number')

saveas(gcf,fullfile(save_path,[script_name,sprintf('_wfm%d.fig',wfm)]));
saveSameSize_150(gcf,'file',fullfile(save_path,[script_name,sprintf('_wfm%d.png',wfm)]),...
                 'format','png');

