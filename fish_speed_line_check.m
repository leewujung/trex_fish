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

dl.r_total = 1.6;            % [km] range from center of wreck
dl.r_diff_div = 2;


% Load 1 file to calculate location params
scat_fname = sprintf('%s_ping%04d.mat',data_path,100);
A = load(fullfile(base_data_path,data_path,scat_fname));


angle_all = -90:30:90;
for iA=1:length(angle_all)

    % Marks and directions for fish expansion and contraction
    wr_ctr = [-2.749, -2.948];   % center of wreck
    dl.a = angle_all(iA);        % [deg] degree from +x-axis
    dl.unit_vec = [cos(dl.a/180*pi),sin(dl.a/180*pi)];
    dl.end = wr_ctr + dl.r_total*[cos(dl.a/180*pi),sin(dl.a/180*pi)];

    dl.r_vec = 0:mean(diff(A.data.range_beam))/dl.r_diff_div:dl.r_total;
    dl.xy_vec = repmat(wr_ctr,length(dl.r_vec),1) +...
        dl.r_vec'*[cos(dl.a/180*pi),sin(dl.a/180*pi)];
    [I,xy_loc,r_proj] = get_xyloc_along_line(A,sm_len,wr_ctr,dl);

    % Plot wanted and nearest x-y locations for comparison
    figure
    plot(dl.xy_vec(:,1),dl.xy_vec(:,2),'.');
    hold on
    plot(xy_loc(:,1),xy_loc(:,2),'x');
    hl = legend('Wanted','Nearest','location','best');
    set(hl,'fontsize',12);
    xlabel('Distance (km)','fontsize',12);
    ylabel('Distance (km)','fontsize',12);
    title(sprintf('Locations on echogram, div=%d, angle=%d',...
                  dl.r_diff_div,dl.a))
    axis equal

    save_fname = sprintf('%s_run%03d_angle%04d_div%d_nearest_xyloc',...
                         script_name,run_num,dl.a,dl.r_diff_div);
    epswrite(fullfile(save_path,[save_fname,'.eps']))
    saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                     'format','png');

    
    % Plot wanted and nearest range from wreck for comparison
    figure
    plot(dl.r_vec,'.');
    hold on
    plot(r_proj,'x');
    hl = legend('Wanted','Nearest','location','best');
    set(hl,'fontsize',12);
    xlabel('Count','fontsize',12);
    ylabel('Range (km)','fontsize',12);
    title(sprintf('Range from wreck, div=%d, angle=%d',...
                  dl.r_diff_div,dl.a))
    
    save_fname = sprintf('%s_run%03d_angle%04d_div%d_nearest_range',...
                         script_name,run_num,dl.a,dl.r_diff_div);
    epswrite(fullfile(save_path,[save_fname,'.eps']))
    saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
                     'format','png');

end