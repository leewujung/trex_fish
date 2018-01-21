% 2018 01 19  Plot bounds of speed limits on fish speed plots


clear

addpath('~/code_matlab_dn/saveSameSize');
addpath(['~/code_git/trex_fish/Triplet_processing_toolbox'])
base_save_path = '~/internal_2tb/trex/figs_results/';
base_data_path = '~/internal_2tb/trex/figs_results/';

% Set up various paths
data_path = 'fish_speed_run131';
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));
div = 4;

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Set params
cmap = 'jet';
color_axis = [180 210];
pingnum_show = [30,90];
medfilt_sz = [11,3];
speed_all = 0:0.1:1;    % range of speed to plot [m/s]
angle_all = 90:-30:-90;  % angles to read data from [deg]


% Load 1 file to calculate location params
scat_data_path = 'subset_beamform_cardioid_coherent_run131';
scat_fname = sprintf('%s_ping%04d.mat',scat_data_path,113);
A = load(fullfile(base_data_path,scat_data_path,scat_fname));


fig = figure('position',[675 10 600 1000]);

% Plot echogram and directional lines
axis_lim = [-4, -1, -5, -1];
subplot(4,2,1)
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
colorbar('location','eastoutside')
%set(gca,'fontsize',12,'xtick',-4.5:1:-1.5,'ytick',-4.5:1:-1.5);
axis(axis_lim);
xlabel('Distance (km)','fontsize',12)
ylabel('Distance (km)','fontsize',12)
set(gca,'layer','top','fontsize',10)


% Plot speed range on fish movement figs
for iA=1:length(angle_all)

    % Load data
    data_fname = sprintf('%s_run%03d_angle%04d_div%d_results.mat',...
                         strjoin(ss(1:2),'_'),run_num,angle_all(iA),div);
    A = load(fullfile(base_data_path,data_path,data_fname));

    % Calculate speed ref lines
    range_1hr = 3600*speed_all'/1e3;  % [km] range traveled in 1hr
    lines_y = [20, 21];  % [hour]
    lines_x = [zeros(length(range_1hr),1),range_1hr];

    % Plot fish movement along a particular direction
    subplot(4,2,iA+1)
    imagesc(A.projected_range_from_wreck,A.time_hh,...
            medfilt2(A.echo_level,[11,3]));
    % Plot speed ref lines
    hold on
    %hx = plot(0,20,'w.','linewidth',2,'markersize',16);
    %hx.Color(4) = 0.4;  % add alpha property
    hl = plot(lines_x,lines_y,'w','linewidth',1);
    for ih=1:length(hl)
        hl(ih).Color(4) = 0.4;
    end

    % Misc
    xlabel('Range from wreck (km)','color','k');
    ylabel('Local time (hour)','color','k');
    title({'',sprintf('%d deg',angle_all(iA))});
    caxis(color_axis)
    set(gca,'ytick',19:0.25:22,'yticklabel',...
            ['19';'  ';'  ';'  ';'20';'  ';'  ';'  ';'21';'  ';'  ';'  ';'22']);
    set(gca,'xtick',0:0.4:1.6);
    ax = gca;
    ax.XAxis.Color = 'k';
    ax.YAxis.Color = 'k';
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = [16:0.25:32];
    ylim(A.time_hh([pingnum_show(1) pingnum_show(2)]))
    colormap(cmap)

end

save_fname = sprintf('%s_run%03d_div%d_medfilt%d-%d',...
                     script_name,run_num,...
                     div,medfilt_sz(1),medfilt_sz(2));
epswrite(fullfile(save_path,[save_fname,'.eps']))
saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                 'format','png');


