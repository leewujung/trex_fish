% 2018 03 09  Adopted from fig_selected_pings_echogram

if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
end


% Set params
run_num = 131;

for wfm_num=1  % loop through waveforms

if run_num==87
    ping_num_all = 1:1000;  % run 087
    color_axis = [180 210];  % wfm 1 of run 131
elseif run_num==131
    ping_num_all = wfm_num:2:1000;
    if wfm_num==2
        color_axis = [178 208];  % wfm 2 of run 131
    else
        color_axis = [180 210];  % wfm 1 of run 131
    end
end
sm_len = 100;
axis_lim = [-4.3 -1.3 -4.5 -1.5];


% Set up various paths
data_path = sprintf('subset_beamform_cardioid_coherent_run%03d',run_num);
ss = strsplit(data_path,'_');
bf_type = ss{2};
coh_type = ss{3};

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d_wfm%d',...
                                            script_name,run_num,wfm_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end


% Loop through all files
fig = figure;
for scat_ping = ping_num_all
    clf
    fname = sprintf('%s_ping%04d.mat',data_path,scat_ping);
    disp(['Plotting ',fname]);
    A = load(fullfile(base_data_path,data_path,fname));

    save_fname = sprintf('%s_%s_%s_run%03d_ping%04d',...
                         script_name,bf_type,coh_type,run_num,scat_ping);
    
    % Plot echogram
    fig = plot_small_echogram(fig,A,sm_len,color_axis,axis_lim);
    title(sprintf('Ping %04d, %02d:%02d:%02d',scat_ping,...
                  A.data.time_hh_local,A.data.time_mm_local,A.data.time_ss_local));
    hcb = colorbar('location','southoutside');
    xlabel(hcb,'Detrended SPL (dB)','fontsize',14,'fontweight','bold');

    % Plot analysis window boundaries
    axis equal
    set(gca,'fontsize',12,'xlim',axis_lim(1:2),'ylim',axis_lim(3:4));
    set(gca,'xtick',-4.3:1:-1.3,'ytick',-4.5:1:-1.5);
    xlabel('X (km)','fontsize',14,'fontweight','bold');
    ylabel('Y (km)','fontsize',14,'fontweight','bold');

    % Save plot
    saveSameSize_150(fig,'file',fullfile(save_path,[save_fname,'.png']),...
                     'format','png');
end

end