% 2018 05 15  Modified from fig_energy_si_sun.m to look at multiple
%             experimental sessions together

clear

addpath('~/code_matlab_dn/saveSameSize');
addpath('~/code_matlab_dn/brewermap');
base_save_path = '~/internal_2tb/trex/figs_results/';
base_data_path = '~/internal_2tb/trex/figs_results/';


% Set up params for multiple sessions
run_num_all = [129,130,131];
wfm = 1;
ping_num_all{1} = 1:2:210;  % run 129
ping_num_all{2} = 1:2:170;  % run 130
ping_num_all{3} = 1:2:1000;  % run 131

sunset = 20+28/60;    % nautical twilight end
sunrise = 4+49/60+24; % nautical twilight start

time_start = 15;
time_end = 30;
time_gap = 1;


% Set up various paths
[~,script_name,~] = fileparts(mfilename('fullpath'));
run_str = strjoin(string(run_num_all),'-');
script_name = sprintf('%s_run%s',script_name,run_str);
save_path = fullfile(base_save_path,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end


% Loop to load data
dum = 'subset_beamform_cardioid_coherent';
ping_time_all = [];
max_W1_cal_all = [];
max_W2_cal_all = [];
E_cal_all = [];
si_W1_all = [];
si_W2_all = [];
for iRUN = 1:length(run_num_all)
    A = summarize_run_fcn(run_num_all(iRUN),ping_num_all{iRUN},ping_num_all{iRUN}(1),0);
    B = load(fullfile(base_data_path,...
             sprintf('%s_run%03d/%s_run%03d_ping0100.mat',...
                     dum,run_num_all(iRUN),dum,run_num_all(iRUN))));

    % Get energy measures
    ping = 1:length(A.ping_time);
    ping_idx = find(A.ping_time>=time_start & A.ping_time<=time_end);
    ping_time = A.ping_time(ping_idx);
    ping_num = ping(ping_idx);
    max_W1 = 20*log10(A.max_W1(ping_idx));
    max_W2 = 20*log10(A.max_W2(ping_idx));
    E = 10*log10(A.energy_in_bnd(ping_idx)/3.56); % beamformed angles are at 1-deg resolution, but
                                                  % actual -3dB beanwidth is 3.56 degrees
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

    ping_time_all = [ping_time_all; NaN; ping_time];
    max_W1_cal_all = [max_W1_cal_all; NaN; max_W1_cal];
    max_W2_cal_all = [max_W2_cal_all; NaN; max_W2_cal];
    E_cal_all = [E_cal_all; NaN; E_cal];
    si_W1_all = [si_W1_all; NaN; si_W1];
    si_W2_all = [si_W2_all; NaN; si_W2];
end


% Sunset/sunrise time
[~,idx_sunset] = min(abs(ping_time_all-sunset));
[~,idx_sunrise] = min(abs(ping_time_all-sunrise));


% Plot: based on ping time =====================================
fig_cmp = figure('position',[675 110 1000 880]);
corder = get(gca,'colororder');

% Day/night timing
set(gca,'position',[.13 .92 .8 .02]);
area(ping_time_all(1:idx_sunset),ones(1,idx_sunset),...
     'facecolor','white','edgecolor','none')
hold on
area(ping_time_all(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1),...
     'facecolor','k','edgecolor','none')
area(ping_time_all(idx_sunrise:end),ones(1,length(ping_time_all)-idx_sunrise+1),...
     'facecolor','white','edgecolor','none')
set(gca,'ytick',[],'xlim',[time_start time_end],...
        'xtick',time_start:time_gap:time_end,'xticklabel','')
title(sprintf('Run %s, wfm %d',run_str,wfm))
set(gca,'layer','top')

% Emax
sub2 = axes;
set(sub2,'position',[.13 .66 .8 .22])
area(ping_time_all(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1)*115,75,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
hw1 = plot(ping_time_all,max_W1_cal_all,'color',corder(1,:),...
           'linewidth',0.5,'linestyle','-');
hw2 = plot(ping_time_all,max_W2_cal_all,'color',corder(2,:),...
           'linewidth',0.5);
axis([time_start time_end 75 115])
grid
ylabel('SPL (dB re 1 \muPa)')
set(gca,'xtick',time_start:time_gap:time_end,'xticklabel','')
ll = legend([hw1,hw2],'W1','W2','location','south');
set(ll,'fontsize',12)
title('Emax')
set(gca,'layer','top')

% Total energy
sub3 = axes;
set(sub3,'position',[.13 .40 .8 .22])
area(ping_time_all(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1)*76,91,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
ht = plot(ping_time_all,E_cal_all,'linewidth',0.5,'color','k');
grid
axis([time_start time_end 76 91])
ylabel('Energy (dB re 1 \muPa^2-s)')
set(gca,'xtick',time_start:time_gap:time_end,'xticklabel','')
title('Total energy')
set(gca,'layer','top')

% Scintillation
sub4 = axes;
set(sub4,'position',[.13 .14 .8 .22])
area(ping_time_all(idx_sunset:idx_sunrise),ones(1,idx_sunrise-idx_sunset+1)*0,20,...
     'facecolor',ones(1,3)*240/255,'edgecolor','none')
hold on
hsi1 = plot(ping_time_all,si_W1_all,'linewidth',0.5,'color',corder(1,:));
hsi2 = plot(ping_time_all,si_W2_all,'linewidth',0.5,'color',corder(2,:));
xlabel('Hour of day')
ylabel('SI');
set(gca,'xtick',time_start:time_gap:time_end,...
        'xticklabel',{num2str([15:23,0:7]')},...
        'ytick',0:5:20)
axis([time_start time_end 0 20])
title('Scintillation index')
grid
set(gca,'layer','top')


saveas(gcf,fullfile(save_path,[script_name,sprintf('_wfm%d_time.fig',wfm)]));
saveSameSize_150(gcf,'file',fullfile(save_path,...
                 [script_name,sprintf('_wfm%d_time.png',wfm)]),'format','png');


