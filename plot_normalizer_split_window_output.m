function plot_normalizer_split_window_output(data_path,ping_num,base_save_path,base_data_path,plot_show_opt,norm_caxis)
% Extract echo level, spectrum, and statistics info from subset beamformed results
% 
% INPUT
%   data_path        path to the folder containing beamformed files
%   ping_num         ping number to be extracted,
%                    or [] for all files in the folder
%   base_data_path   path to the base results folder
%   base_save_path   path to the base folder where extracted results are saved
%   plot_show_opt    whether to show plot or not while processing     
%   norm_caxis       color axis range of normalized output
%
% Wu-Jung Lee | leewujung@gmail.com
% 2017 02 19  Adapted from echo_info_fcn()

if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath(['~/internal_2tb/Dropbox/0_CODE/trex_fish/Triplet_processing_toolbox'])
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\trex_fish\Triplet_processing_toolbox')
end

%base_data_path='~/internal_2tb/trex/figs_results/';
%base_save_path='~/internal_2tb/trex/figs_results/';
%data_path='subset_beamform_cardioid_coherent_run131';
%ping_num=10;
%plot_show_opt=1;

% Set up various paths
ss = strsplit(data_path,'_');
run_num = str2double(ss{end}(4:end));

[~,script_name,~] = fileparts(mfilename('fullpath'));
script_name = script_name(1:end-4);
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
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

% Set params
cmap = 'jet';
sm_len = 100;
axis_lim = [-5 -1 -5 -1];
ori_caxis = [180 210];
norm_param.sm_len = sm_len;    % smooth length
norm_param.aux_m = 200;        % length of auxiliary band in [m]
norm_param.guard_num_bw = 2;   % 2/BW


% Set up figure
fig = figure('position',[280 60 1000 500]);
corder = get(gca,'colororder');
if ~plot_show_opt  % if not showing figure
    set(fig,'visible','off');
end

% Loop through each ping
for iP=1:ping_len

    % Load file and set filename
    if isempty(ping_num)  % if processing all files in the folder
        fname = data_files(iP).name;
        ping_num_curr = str2double(fname(end-7:end-4));
    else
        fname = sprintf('%s_ping%04d.mat',...
                        data_path,ping_num(iP));
        ping_num_curr = ping_num(iP);
    end
    disp(['Processing ',fname])
    A = load(fullfile(base_data_path,data_path,fname));

    save_fname = sprintf('%s_run%03d_ping%04d',script_name,run_num,ping_num_curr);
    
    % Get normalizer output
    [beamform_norm,meta] = normalizer_split_window(A,norm_param);

    % Plotting
    title_text = sprintf('Run %d, Ping %d, %02d:%02d:%02d',...
                         run_num,ping_num_curr,A.data.time_hh_local,...
                         A.data.time_mm_local,A.data.time_ss_local);

    figure(fig)
    h_ori = plot_small_echogram(subplot(121),A,sm_len,ori_caxis,axis_lim);

    subplot(122)
    cla
    h_norm = pcolor(meta.X/1e3,meta.Y/1e3,10*log10(beamform_norm));
    hold on
    set(h_norm,'edgecolor','none');
    axis equal
    colormap(jet)
    colorbar('location','southoutside');
    caxis(norm_caxis)
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    
    mtit(title_text,'fontsize',16);
    
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');

end


if ~plot_show_opt  % if not showing figure
    close(fig)
end

