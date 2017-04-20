% 2017 02 24  Time series of Emax, total energy, SI, with sunrise/sunset info
%             for run131

clear

if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/brewermap');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\MATLAB\brewermap');
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Set up params
run_num = 131;
wfm = 2;
if run_num==87
    ping_num = wfm:1:1000;   % run 131
    dates = 'May 10';
    sunset = 20+23/60;    % nautical twilight end
    sunrise = 4+54/60+24; % nautical twilight start
elseif run_num==131
    ping_num = wfm:2:1000;   % run 131
    dates = 'May 16';
    sunset = 20+28/60;    % nautical twilight end
    sunrise = 4+49/60+24; % nautical twilight start
    sel_ping = ([49,95,103,113,441,455,507,589,781,795,797,813]-1)/2+1; % pings to plot
    if wfm==2
        sel_ping = sel_ping+1;
    end
    % original selection for echo pdf: 95,103,441,455,781,795,813
    % original selection for echogram: 49,103,113,507,781,797,813
                      
end

% Set up various paths
[~,script_name,~] = fileparts(mfilename('fullpath'));
script_name = sprintf('%s_run%03d',script_name,run_num);
save_path = fullfile(base_save_path,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end


% Load data
A = summarize_run_fcn(run_num,ping_num,ping_num(1),0);
dum = 'subset_beamform_cardioid_coherent';
B = load(fullfile(base_data_path,...
    sprintf('%s_run%03d/%s_run%03d_ping0100.mat',...
            dum,run_num,dum,run_num)));

% Set plotting params
time_start = 19;
time_end = 30;
time = time_start:0.01:time_end;

% Get energy measures
ping = 1:length(A.ping_time);
ping_idx = find(A.ping_time>=time_start & A.ping_time<=time_end);
ping_time = A.ping_time(ping_idx);
ping_num = ping(ping_idx);
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
[~,idx_sunset_ping] = min(abs(ping_time-sunset));
[~,idx_sunrise_ping] = min(abs(ping_time-sunrise));

% Plot: based on ping time =====================================
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
title(sprintf('Run %d, Wfm %d',run_num,wfm))
set(gca,'layer','top')

sub2 = axes;
set(sub2,'position',[.13 .68 .8 .22])
area(time(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1)*115,75,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
hw1 = plot(ping_time,max_W1_cal,'color',corder(1,:),'linewidth',0.5,'linestyle','-');
hw2 = plot(ping_time,max_W2_cal,'color',corder(2,:),'linewidth',0.5);
if exist('sel_ping')
    for iS=1:length(sel_ping)
        hsel = plot([1 1]*ping_time(sel_ping(iS)-ping_idx(1)+1),...
                [75 114],'k--');
    end
end
% hv1 = plot(time(idx_sunset)*[1 1],[75 115],'color',[1 1 1]*170/255,'linewidth',1);
% hv2 = plot(time(idx_sunrise)*[1 1],[75 115],'color',[1 1 1]*170/255,'linewidth',1);
axis([19 30 75 115])
grid
ylabel('SPL (dB re 1 \muPa)')
set(gca,'xtick',19:30,'xticklabel','')
ll = legend([hw1,hw2],'W1','W2','location','south');
set(ll,'fontsize',12)
title('Emax')
set(gca,'layer','top')

sub3 = axes;
set(sub3,'position',[.13 .42 .8 .22])
area(time(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1)*19,28,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
ht = plot(ping_time,E_cal,'linewidth',0.5,'color','k');
% hv1 = plot(time(idx_sunset)*[1 1],[19 27],'color',[1 1 1]*170/255,'linewidth',1);
% hv2 = plot(time(idx_sunrise)*[1 1],[19 27],'color',[1 1 1]*170/255,'linewidth',1);
if exist('sel_ping')
    for iS=1:length(sel_ping)
        hsel = plot([1 1]*ping_time(sel_ping(iS)-ping_idx(1)+1),...
                [19 28],'k--');
    end
end
if wfm==1
    axis([19 30 19 28])
else
    axis([19 30 19 27])
end
grid
ylabel('Energy (dB re 1 \muPa^2-s)')
set(gca,'xtick',19:30,'xticklabel','')
title('Total energy')
set(gca,'layer','top')

sub4 = axes;
set(sub4,'position',[.13 .16 .8 .22])
area(time(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1)*-5,30,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
hsi1 = plot(ping_time,si_W1,'linewidth',0.5,'color',corder(1,:));
hsi2 = plot(ping_time,si_W2,'linewidth',0.5,'color',corder(2,:));
if exist('sel_ping')
    for iS=1:length(sel_ping)
        hsel = plot([1 1]*ping_time(sel_ping(iS)-ping_idx(1)+1),...
                [-5 30],'k--');
    end
end
% hv1 = plot(time(idx_sunset)*[1 1],[0 10],'color',[1 1 1]*170/255,'linewidth',1);
% hv2 = plot(time(idx_sunrise)*[1 1],[0 10],'color',[1 1 1]*170/255,'linewidth',1);
xlabel('Hour of day')
ylabel('SI');
set(gca,'xtick',19:30,'xticklabel',{num2str([19:23,0:7]')},...
        'ytick',0:5:20)
axis([19 30 0 20])
title('Scintillation index')
grid
set(gca,'layer','top')

subx = axes;
set(subx,'Position',[.13 .09 .8 1e-12]);
if run_num==131
    set(subx,'xlim',[0 440],'xtick',0:40:440)
elseif run_num==87
    set(subx,'xlim',[80 980],'xtick',80:100:1000)
end
xlabel('Ping number')

saveas(gcf,fullfile(save_path,[script_name,sprintf('_wfm%d_time.fig',wfm)]));
saveSameSize_150(gcf,'file',fullfile(save_path,...
                 [script_name,sprintf('_wfm%d_time.png',wfm)]),'format','png');


% Plot: based on ping number ================================
fig_cmp = figure('position',[675 110 600 880]);
corder = get(gca,'colororder');

set(gca,'position',[.13 .94 .8 .02]);
area(ping_num(1:idx_sunset_ping),ones(1,idx_sunset_ping),...
     'facecolor','white','edgecolor','none')
hold on
area(ping_num(idx_sunset_ping:idx_sunrise_ping),...
     ones(1,idx_sunrise_ping-idx_sunset_ping+1),...
     'facecolor','k','edgecolor','none')
area(ping_num(idx_sunrise_ping:end),...
     ones(1,length(ping_num)-idx_sunrise_ping+1),...
     'facecolor','white','edgecolor','none')
if run_num==131
    set(gca,'ytick',[],'xlim',[0 440],'xtick',0:40:440,'xticklabel','')
elseif run_num==87
    set(gca,'ytick',[],'xlim',[80 980],'xtick',80:100:980,'xticklabel','')
end
title(sprintf('Run %d, Wfm %d',run_num,wfm))
set(gca,'layer','top')

sub2 = axes;
set(sub2,'position',[.13 .68 .8 .22])
area(ping_num(idx_sunset_ping:idx_sunrise_ping),...
     ones(1,idx_sunrise_ping-idx_sunset_ping+1)*115,75,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
hw1 = plot(ping_num,max_W1_cal,'color',corder(1,:),'linewidth',0.5,'linestyle','-');
hw2 = plot(ping_num,max_W2_cal,'color',corder(2,:),'linewidth',0.5);
% hv1 = plot(time(idx_sunset)*[1 1],[75 115],'color',[1 1 1]*170/255,'linewidth',1);
% hv2 = plot(time(idx_sunrise)*[1 1],[75 115],'color',[1 1 1]*170/255,'linewidth',1);
if exist('sel_ping')
    for iS=1:length(sel_ping)
        hsel = plot([1 1]*ping_num(sel_ping(iS)-ping_idx(1)+1),...
                [75 115],'k--');
    end
end
if run_num==131
    axis([0 440 75 115])
    set(gca,'xtick',0:40:440,'xticklabel','')
elseif run_num==87
    axis([80 980 75 115])
    set(gca,'xtick',80:100:980,'xticklabel','')
end
grid
ylabel('SPL (dB re 1 \muPa)')
ll = legend([hw1,hw2],'W1','W2','location','south');
set(ll,'fontsize',12)
title('Emax')
set(gca,'layer','top')

sub3 = axes;
set(sub3,'position',[.13 .42 .8 .22])
area(ping_num(idx_sunset_ping:idx_sunrise_ping),...
     ones(1,idx_sunrise_ping-idx_sunset_ping+1)*19,28,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
he = plot(ping_num,E_cal,'linewidth',0.5,'color','k');
% hv1 = plot(time(idx_sunset)*[1 1],[19 27],'color',[1 1 1]*170/255,'linewidth',1);
% hv2 = plot(time(idx_sunrise)*[1 1],[19 27],'color',[1 1 1]*170/255,'linewidth',1);
if exist('sel_ping')
    for iS=1:length(sel_ping)
        hsel = plot([1 1]*ping_num(sel_ping(iS)-ping_idx(1)+1),...
                [19 28],'k--');
    end
end
if run_num==131
    if wfm==1
        axis([0 440 19 28])
    else
        axis([0 440 19 27])
    end
    set(gca,'xtick',0:40:440,'xticklabel','')
elseif run_num==87
    axis([80 980 19 28])
    set(gca,'xtick',80:100:980,'xticklabel','')
end
grid
ylabel('Energy (dB re 1 \muPa^2-s)')
title('Total energy')
set(gca,'layer','top')

sub4 = axes;
set(sub4,'position',[.13 .16 .8 .22])
area(ping_num(idx_sunset_ping:idx_sunrise_ping),...
     ones(1,idx_sunrise_ping-idx_sunset_ping+1)*-5,30,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
hsi1 = plot(ping_num,si_W1,'linewidth',0.5,'color',corder(1,:));
hsi2 = plot(ping_num,si_W2,'linewidth',0.5,'color',corder(2,:));
if exist('sel_ping')
    for iS=1:length(sel_ping)
        hsel = plot([1 1]*ping_num(sel_ping(iS)-ping_idx(1)+1),...
                [-5 30],'k--');
    end
end
xlabel('Ping number')
ylabel('SI');
if run_num==131
    set(gca,'xtick',0:40:440)
    axis([0 440 0 20])
else
    set(gca,'xtick',80:100:980)
    axis([80 980 0 20])
end
title('Scintillation index')
grid
set(gca,'layer','top')

subx = axes;
set(subx,'Position',[.13 .09 .8 1e-12]);
set(subx,'xlim',[0 11],'xtick',0:11,'xticklabel',[19:23,0:6])
xlabel('Hour of day')

saveas(gcf,fullfile(save_path,...
                    [script_name,sprintf('_wfm%d_pingnum.fig',wfm)]));
saveSameSize_150(gcf,'file',fullfile(save_path,...
                 [script_name,sprintf('_wfm%d_pingnum.png',wfm)]),'format','png');
