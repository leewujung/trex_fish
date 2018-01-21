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
pingnum_show = 100;
medfilt_sz = [11,3];
speed_all = 0:0.1:1;    % range of speed to plot [m/s]
angle_all = -90:30:90;  % angles to read data from [deg]


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
    figure
    imagesc(A.projected_range_from_wreck,A.time_hh,...
            medfilt2(A.echo_level,[11,3]));
    % Plot speed ref lines
    hold on
    hx = plot(0,20,'w.','linewidth',2,'markersize',16);
    hx.Color(4) = 0.4;  % add alpha property
    hl = plot(lines_x,lines_y,'w','linewidth',1);
    for ih=1:length(hl)
        hl(ih).Color(4) = 0.4;
    end

    % Misc
    xlabel('Range from center of wreck (km)','color','k');
    ylabel('Local time (hour)','color','k');
    title(sprintf('Echo level, %d deg, medfilt [%d,%d]',...
                  angle_all(iA),medfilt_sz(1),medfilt_sz(2)));
    caxis(color_axis)
    colorbar
    set(gca,'ytick',16:0.25:32,'yticklabel',num2str([16:0.25:22,0:0.25:8]'));    
    ylim(A.time_hh([1 pingnum_show]))
    colormap(cmap)
    ax = gca;
    ax.XAxis.Color = 'k';
    ax.YAxis.Color = 'k';

    save_fname = sprintf('%s_run%03d_angle%04d_div%d_medfilt%d-%d',...
                         script_name,run_num,A.directional_line.a,...
                         div,medfilt_sz(1),medfilt_sz(2));
    epswrite(fullfile(save_path,[save_fname,'.eps']))
    saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                     'format','png');

end

