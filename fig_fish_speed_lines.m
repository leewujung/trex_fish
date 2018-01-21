% 2018 01 19  Plot the directions along which the fish speed is
%             estimated


clear

addpath('~/code_matlab_dn/saveSameSize');
addpath(['~/code_git/trex_fish/Triplet_processing_toolbox'])
base_save_path = '~/internal_2tb/trex/figs_results/';
base_data_path = '~/internal_2tb/trex/figs_results/';

% Set up various paths
data_path = 'subset_beamform_cardioid_coherent_run131';
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end


% Set params
cmap = 'jet';
axis_lim = [-5 -1 -5 -1];
color_axis = [180 210];
angle_all = -90:30:90;


% Load 1 file to calculate location params
scat_fname = sprintf('%s_ping%04d.mat',data_path,113);
A = load(fullfile(base_data_path,data_path,scat_fname));


% Plot echogram
figure
plot_small_echogram(gca,A,100,color_axis,axis_lim);
hold on

for iA=1:length(angle_all)
    
    % Marks and directions for fish expansion and contraction
    wr_ctr = [-2.749, -2.948];   % center of wreck
    dl.a = angle_all(iA);        % [deg] degree from +x-axis
    dl.r_total = 1.6;              % [km] range from center of wreck
    dl.unit_vec = [cos(dl.a/180*pi),sin(dl.a/180*pi)];
    dl.end = wr_ctr + dl.r_total*[cos(dl.a/180*pi),sin(dl.a/180*pi)];

    % Plot echogram overlaid with specified direction
    plot([wr_ctr(1) dl.end(1)],[wr_ctr(2) dl.end(2)],'m','linewidth',1);
end

colorbar('location','southoutside')
%set(gca,'fontsize',12,'xtick',-4.5:1:-1.5,'ytick',-4.5:1:-1.5);
axis(axis_lim);
xlabel('Distance (km)','fontsize',16)
ylabel('Distance (km)','fontsize',16)
set(gca,'layer','top')

save_fname = script_name;
epswrite(fullfile(save_path,[save_fname,'.eps']))
saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                 'format','png');

