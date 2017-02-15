function h = plot_small_echogram(A,coloraxis)
% Function to plot echogram in focused area

addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');

data_path = 'subset_beamform_cardioid_coherent_run131';
base_data_path = '/home/wu-jung/internal_2tb/trex/figs_results';
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
ping_num = 22;
sm_len = 100;

% Plotting
fname = sprintf('%s_ping%04d.mat',...
                data_path,ping_num);
A = load(fullfile(base_data_path,data_path,fname));

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
[amesh,rmesh] = meshgrid(A.data.polar_angle,A.data.range_beam_sm);
[X,Y] = pol2cart(amesh/180*pi,rmesh);

% Echo level calibration
total_gain_crd_coh = A.param.gain_load -...
                     A.param.gain_sys -...
                     A.param.gain_beamform -...
                     A.param.gain_pc;

% Rough transmission loss compensation
TL_comp = repmat(30*log10(A.data.range_beam_sm)',...
                 1,size(X,2));

% Plot
h = figure
h1 = pcolor(X/1e3,Y/1e3,20*log10(env_sm)+...
            total_gain_crd_coh-3 +TL_comp);
hold on
set(h1,'edgecolor','none');
axis equal
colormap(jet)
colorbar
caxis(coloraxis)
xlim(sort(A.extract_param.xlim,'ascend'))
ylim(sort(A.extract_param.ylim,'ascend'))
xlabel('Distance (km)','fontsize',14)
ylabel('Distance (km)','fontsize',14)
