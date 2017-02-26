% 2017 02 25  Echogram of the study area for the selected pings in run 131

addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');

data_path = 'subset_beamform_cardioid_coherent_run131';
base_data_path = '/home/wu-jung/internal_2tb/trex/figs_results';
base_save_path = '/home/wu-jung/internal_2tb/trex/figs_results';

% Set params
ping_num = [13,103,113,261,441,507,651,781,797,813];
sm_len = 100;
color_axis = [180 210];
axis_lim = [-4.5 -1.5 -4.5 -1.5];

% Set up various paths
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));
bf_type = ss{2};
coh_type = ss{3};

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Ping range
if isempty(ping_num)
    data_files = dir(fullfile(base_data_path,data_path,'*.mat'));
    ping_len = length(data_files);
else
    ping_len = length(ping_num);
end

% Analysis Window ranges
no_rr = [3.60,3.92];  % Area not including wreck: W2
no_aa = [-2.45,-2.27];
wr_rr = [3.92,4.12];  % USS Strength shipwreck: W1
wr_aa = [-2.40,-2.21];

% Boundary for total energy
BND = load(fullfile(base_data_path,'bnd.mat'));

% Loop through all files
fig = figure;
for iP=1:ping_len
    clf
    if isempty(ping_num)  % if processing all files in the folder
        fname = data_files(iP).name;
        scat_ping = str2double(fname(end-7:end-4));
    else
        fname = sprintf('%s_ping%04d.mat',...
                        data_path,ping_num(iP));
        scat_ping = ping_num(iP);
    end
    disp(['Plotting ',fname]);
    A = load(fullfile(base_data_path,data_path,fname));

    if iP==1
        % Get analysis window coordinates
        [no_r_idx,no_a_idx] = ...
            get_ra_idx_crd_coh(A.data.range_beam,A.data.polar_angle,...
                                             no_rr*1e3,no_aa/pi*180);
        [wr_r_idx,wr_a_idx] = ...
            get_ra_idx_crd_coh(A.data.range_beam,A.data.polar_angle,...
                                             wr_rr*1e3,wr_aa/pi*180);
        [no_pie_x,no_pie_y] = get_pie_outline(A.data.polar_angle(no_a_idx),...
                                              A.data.range_beam(no_r_idx));
        [wr_pie_x,wr_pie_y] = get_pie_outline(A.data.polar_angle(wr_a_idx),...
                                              A.data.range_beam(wr_r_idx));
    end

    save_fname = sprintf('%s_%s_%s_run%03d_ping%04d',...
                         script_name,bf_type,coh_type,run_num,scat_ping);
    
    % Plot echogram
    fig = plot_small_echogram(fig,A,sm_len,color_axis,axis_lim);
    title(sprintf('Ping %04d, %02d:%02d:%02d',scat_ping,...
                  A.data.time_hh_local,A.data.time_mm_local,A.data.time_ss_local));

    % Plot analysis window boundaries
    hold on
    plot(no_pie_x/1e3,no_pie_y/1e3,'m','linewidth',2);
    plot(wr_pie_x/1e3,wr_pie_y/1e3,'m','linewidth',2);
    plot(BND.xg,BND.yg,'m--','linewidth',2)
    hold off
    xlabel('Distance (km)','fontsize',16)
    ylabel('Distance (km)','fontsize',16)
    set(gca,'fontsize',14);

    % Save plot
    %    epswrite(fullfile(save_path,[save_fname,'.eps']));
    saveSameSize_150(fig,'file',fullfile(save_path,[save_fname,'.png']),...
                     'format','png');
end