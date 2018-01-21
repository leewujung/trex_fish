% 2018 01 17  Calculate expansion and shrinking speed of fish
%             aggregation


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

% Ping range
ping_all = 1:2:1000;  % use LF waveform

% Set params
cmap = 'jet';
sm_len = 1;
axis_lim = [-5 -1 -5 -1];
color_axis = [180 210];

S.param.ping_all = ping_all;
S.param.cmap = cmap;
S.param.sm_len = sm_len;
S.param.axis_lim = axis_lim;
S.param.color_axis = color_axis;


% Load 1 file to calculate location params
scat_fname = sprintf('%s_ping%04d.mat',data_path,100);
A = load(fullfile(base_data_path,data_path,scat_fname));


angle_all = -90:30:90;
for iA=1:length(angle_all)

    % Marks and directions for fish expansion and contraction
    wr_ctr = [-2.749, -2.948];   % center of wreck
    dl.a = angle_all(iA);        % [deg] degree from +x-axis
    dl.r_total = 1.6;            % [km] range from center of wreck
    dl.r_diff_div = 4;
    dl.unit_vec = [cos(dl.a/180*pi),sin(dl.a/180*pi)];
    dl.end = wr_ctr + dl.r_total*[cos(dl.a/180*pi),sin(dl.a/180*pi)];

    dl.r_vec = 0:mean(diff(A.data.range_beam))/dl.r_diff_div:dl.r_total;
    dl.xy_vec = repmat(wr_ctr,length(dl.r_vec),1) +...
        dl.r_vec'*[cos(dl.a/180*pi),sin(dl.a/180*pi)];
    [I,xy_loc,r_proj] = get_xyloc_along_line(A,sm_len,wr_ctr,dl);

    A.wr_ctr = wr_ctr;
    S.directional_line = dl;
    S.index_selected = I;
    S.xy_loc_selected = xy_loc;
    S.projected_range_from_wreck = r_proj;
    

    % Plot echogram overlaid with specified direction
    figure
    plot_small_echogram(gca,A,100,color_axis,axis_lim);
    hold on
    plot([wr_ctr(1) dl.end(1)],[wr_ctr(2) dl.end(2)],'m:','linewidth',2);
    colorbar('location','southoutside')
    set(gca,'fontsize',12,'xtick',-4.3:1:-1.3,'ytick',-4.5:1:-1.5);
    axis([-4.3 -1.3 -4.5 -1.5]);
    xlabel('Distance (km)','fontsize',16)
    ylabel('Distance (km)','fontsize',16)
    set(gca,'layer','top')

    save_fname = sprintf('%s_run%03d_angle%04d_echogram',script_name,run_num,dl.a);
    epswrite(fullfile(save_path,[save_fname,'.eps']))
    saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                     'format','png');


    for iP=1:length(ping_all)

        % Load file and set filename
        ping_num = ping_all(iP);
        scat_fname = sprintf('%s_ping%04d.mat',data_path,ping_num);
        save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num);
        disp(['Processing ',scat_fname])
        A = load(fullfile(base_data_path,data_path,scat_fname));

        % Calculate echo level by 1D interpolation along the specified
        % direction. Range from xy_loc to wr_ctr calculated by projection.
        echo_level(iP,:) = get_echo_level_along_line(A,sm_len,I,r_proj,dl);

        % Get time stamps in mins
        if A.data.time_hh_local<15
            hh = A.data.time_hh_local+24;
        else
            hh = A.data.time_hh_local;
        end
        time_hh(iP) = hh+A.data.time_mm_local/60+A.data.time_ss_local/3600;

    end
    S.echo_level = echo_level;
    S.time_hh = time_hh;

    % Save results
    save_fname = sprintf('%s_run%03d_angle%04d_div%d_results',...
                         script_name,run_num,dl.a,dl.r_diff_div);
    save(fullfile(save_path,[save_fname,'.mat']),'-struct','S');



    % Plotting
    medfilt_sz = [3,3;  5,3;  11,3;  15,3;  21,3];

    % -- raw echo level --
    figure
    imagesc(r_proj,time_hh,echo_level);
    xlabel('Range from center of wreck (km)');
    ylabel('Local time (hour)');
    title('Raw echo level');
    caxis([180 210])
    colorbar
    set(gca,'ytick',16:2:32,'yticklabel',num2str([16:2:22,0:2:8]'));

    save_fname = sprintf('%s_run%03d_angle%04d_div%d_raw', ...
                         script_name,run_num,dl.a,dl.r_diff_div);
    epswrite(fullfile(save_path,[save_fname,'.eps']))
    saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                     'format','png');

    % -- median filtered echo level --
    for iM=1:size(medfilt_sz)
        figure
        imagesc(r_proj,time_hh,medfilt2(echo_level,medfilt_sz(iM,:)));
        xlabel('Range from center of wreck (km)');
        ylabel('Local time (hour)');
        title(sprintf('Echo level, medfilt [%d,%d]',medfilt_sz(iM,1),medfilt_sz(iM,2)));
        caxis([180 210])
        colorbar
        set(gca,'ytick',16:2:32,'yticklabel',num2str([16:2:22,0:2:8]'));    
        
        save_fname = sprintf('%s_run%03d_angle%04d_div%d_medfilt%d-%d',...
                             script_name,run_num,dl.a,dl.r_diff_div, ...
                             medfilt_sz(iM,1),medfilt_sz(iM,2));
                epswrite(fullfile(save_path,[save_fname,'.eps']))
        saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
        saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                         'format','png');
    end

    close all


end