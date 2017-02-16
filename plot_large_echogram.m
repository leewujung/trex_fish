% Function to plot overall echogram

addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');

data_path = 'beamform_cardioid_coherent_run087';
base_data_path = '/media/wu-jung/wjlee_apl_1/trex_results/';
base_save_path = '/home/wu-jung/internal_2tb/trex/figs_results';

% Set up various paths
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));
bf_type = ss{2};
coh_type = ss{3};

[~,script_name,~] = fileparts(mfilename('fullpath'));
script_name = script_name(1:end-4);
save_path = fullfile(base_save_path,...
            sprintf('%s_%s_%s_run%03d',script_name,bf_type,coh_type,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Set params
ping_num = 1;
sm_len = 100;

% Plotting
fname = sprintf('beamform_%s_%s_run%03d_ping%04d.mat',...
                bf_type,coh_type,run_num,ping_num);
A = load(fullfile(base_data_path,data_path,fname));

save_fname = sprintf('%s_%s_%s_run%03d_ping%04d',...
                     script_name,bf_type,coh_type,run_num,ping_num);

% Get envelope and smooth/subsample
env = nan(size(A.data.beam_mf_in_time));
env_sm = nan(size(env));
for iA=1:size(env,2)
    env(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
    env_sm(:,iA) = smooth(env(:,iA),sm_len);
end
env_sm = env_sm(1:sm_len:end,:);

% Get plotting params
A.data.range_beam_sm = A.data.range_beam(1:sm_len:end);
[~,cut_in_range] = min(abs(A.data.range_beam_sm));  % range closest to 0m
cut_in_angle = find(abs(diff(A.data.polar_angle))>1);  % angle jump during beamforming

[amesh1,rmesh1] = meshgrid(A.data.polar_angle(1:cut_in_angle),...
                           A.data.range_beam_sm(cut_in_range:end));
[amesh2,rmesh2] = meshgrid(A.data.polar_angle(cut_in_angle+1:end),...
                           A.data.range_beam_sm(cut_in_range:end));
[X1,Y1] = pol2cart(amesh1/180*pi,rmesh1);
[X2,Y2] = pol2cart(amesh2/180*pi,rmesh2);

% Echo level calibration
total_gain_crd_coh = A.param.gain_load -...
                     A.param.gain_sys -...
                     A.param.gain_beamform -...
                     A.param.gain_pc;

% Rough transmission loss compensation
TL_comp = repmat(30*log10(A.data.range_beam_sm(cut_in_range:end))',...
                 1,size(X1,2));

% Get bathymetry
[Map_X,Map_Y,Map_Z,wrecgps] = func_load_map_targets(A.param.map_coord);


% Plot
figure
h1 = pcolor(X1/1e3,Y1/1e3,...
            20*log10(env_sm(cut_in_range:end,1:cut_in_angle))+...
            total_gain_crd_coh-3 +TL_comp);
hold on
h2 = pcolor(X2/1e3,Y2/1e3,...
            20*log10(env_sm(cut_in_range:end,cut_in_angle+1:end))+...
            total_gain_crd_coh-3 +TL_comp);
set(h1,'edgecolor','none');
set(h2,'edgecolor','none');
axis equal
colormap(jet)
caxis([180 210])
axis([-7 7 -7 7])
xlabel('Distance (km)','fontsize',14)
ylabel('Distance (km)','fontsize',14)

gray = [1 1 1]*130/255;
[c,hmap]=contour(Map_X/1000,Map_Y/1000,Map_Z,[0:-4:-30],'color',gray);
clabel(c,hmap,'fontsize',8,'linewidth',0.5,'Color',gray);

title(sprintf('Ping %04d, %02d:%02d:%02d',scat_ping,...
              A.data.time_hh_local,A.data.time_mm_local,A.data.time_ss_local))

% Save plot
saveSameSize_300(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                 'format','png');
