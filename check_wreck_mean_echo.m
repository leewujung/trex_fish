% 2017 09 08  Check the mean echo from the shipwreck during the night to
%             determine how strong it is compared to fish echoes

% Set up various paths
if isunix
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/saveSameSize');
    addpath('~/internal_2tb/Dropbox/0_CODE/MATLAB/epsutil');
    addpath('~/internal_2tb/trex/trex_fish_code/Triplet_processing_toolbox');
    base_save_path = '~/internal_2tb/trex/figs_results/';
    base_data_path = '~/internal_2tb/trex/figs_results/';
else
    addpath('F:\Dropbox\0_CODE\MATLAB\saveSameSize');
    addpath('F:\Dropbox\0_CODE\MATLAB\epsutil');
    addpath('F:\trex\trex_fish_code\Triplet_processing_toolbox');
    base_save_path = 'F:\trex\figs_results';
    base_data_path = 'F:\trex\figs_results';
end

% Set params
run_num = 131;
%ping_num = 70:2:300;
ping_num = 301:2:500;

% Set up various paths
data_path = sprintf('subset_beamform_cardioid_coherent_run%03d',run_num);

[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,sprintf('%s_run%03d',script_name,run_num));
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Set params
cmap = 'jet';
sm_len = 100;
axis_lim = [-4.3 -1.3 -4.5 -1.5];
norm_detail_plot = 0;


% Set up figure
fig = figure('position',[280 60 800 560]);

% Loop through each ping for averaging
beam_mf_accum = [];
cnt = 0;
for iP=1:length(ping_num)
    
    fname = sprintf('%s_ping%04d.mat', data_path,ping_num(iP));
    save_fname = sprintf('%s_run%03d_avgSincePing%04d_ping%04d',...
                         script_name,run_num,ping_num(1),ping_num(iP));

    disp(['Processing ',fname])
    A = load(fullfile(base_data_path,data_path,fname));

    if iP==1
        % Get plotting params
        range_beam_sm = A.data.range_beam(1:sm_len:end);
        [amesh,rmesh] = meshgrid(A.data.polar_angle,range_beam_sm);
        [X,Y] = pol2cart(amesh/180*pi,rmesh);

        % Echo level calibration
        total_gain_crd_coh = A.param.gain_load -...
            A.param.gain_sys -...
            A.param.gain_beamform -...
            A.param.gain_pc;
    end

    %beam_mf_accum(iP,:,:) = A.data.beam_mf_in_time;
    if iP==1
        beam_mf_accum = A.data.beam_mf_in_time;
    else
        beam_mf_accum = beam_mf_accum + A.data.beam_mf_in_time;
    end
    cnt = cnt+1;

    % Get envelope and smooth/subsample for AVERAGED PING
    %beam_mf_mean = squeeze(mean(beam_mf_accum,1));
    if mod(iP,5)==0
        beam_mf_mean = beam_mf_accum/cnt;
        env_mean = nan(size(beam_mf_mean));
        env_sm_mean = nan(size(env_mean));
        for iA=1:size(env_mean,2)
            env_mean(:,iA) = abs(hilbert(beam_mf_mean(:,iA)));
            if sm_len==1
                env_sm_mean(:,iA) = env_mean(:,iA);
            else
                env_sm_mean(:,iA) = smooth(env_mean(:,iA),sm_len);
            end
        end
        env_sm_mean = env_sm_mean(1:sm_len:end,:);

        % Get envelope and smooth/subsample for SINGLE PING
        env = nan(size(A.data.beam_mf_in_time));
        env_sm = nan(size(env));
        for iA=1:size(env,2)
            env(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
            if sm_len==1
                env_sm(:,iA) = env(:,iA);
            else
                env_sm(:,iA) = smooth(env(:,iA),sm_len);
            end
        end
        env_sm = env_sm(1:sm_len:end,:);


        % Plot
        figure(fig)
        subplot(121)   % raw ping
        cla
        h1 = pcolor(X/1e3,Y/1e3,20*log10(env_sm)+...
                    total_gain_crd_coh-3);
        hold on
        set(h1,'edgecolor','none');
        axis equal
        colormap(jet)
        caxis([65 95])
        colorbar('Ticks',65:10:95,'location','southoutside')
        axis(axis_lim)
        xlabel('Distance (km)','fontsize',14)
        ylabel('Distance (km)','fontsize',14)
        set(gca,'fontsize',12)
        title(sprintf('Ping %04d, %02d:%02d:%02d',ping_num(iP),...
                      A.data.time_hh_local,A.data.time_mm_local,A.data.time_ss_local));
        subplot(122)  % averaged ping
        cla
        h1 = pcolor(X/1e3,Y/1e3,20*log10(env_sm_mean)+...
                    total_gain_crd_coh-3);
        hold on
        set(h1,'edgecolor','none');
        axis equal
        colormap(jet)
        caxis([65 95])
        colorbar('Ticks',65:10:95,'location','southoutside')
        axis(axis_lim)
        xlabel('Distance (km)','fontsize',14)
        ylabel('Distance (km)','fontsize',14)
        set(gca,'fontsize',12)
        title(sprintf('Averaged since ping %04d',ping_num(1)));

        %keyboard
        saveSameSize_res(gcf,120,'file',fullfile(save_path,[save_fname,'.png']),...
                         'format','png');

        end

end


    %if iP==1
    %    beam_mf_accum = A.data.beam_mf_in_time;
    %else
    %    beam_mf_accum = beam_mf_accum+A.data.beam_mf_in_time;
    %end

    if 0
    % Get envelope and smooth/subsample
    beam_mf_accum = beam_mf_accum/iP;
    env_accum = nan(size(beam_mf_accum));
    env_sm_accum = nan(size(env_accum));
    for iA=1:size(env_accum,2)
        env_accum(:,iA) = abs(hilbert(beam_mf_accum(:,iA)));
        if sm_len==1
            env_sm_accum(:,iA) = env_accum(:,iA);
        else
            env_sm_accum(:,iA) = smooth(env_accum(:,iA),sm_len);
        end
    end
    env_sm_accum = env_sm_accum(1:sm_len:end,:);

    % Get envelope and smooth/subsample
    env = nan(size(A.data.beam_mf_in_time));
    env_sm = nan(size(env));
    for iA=1:size(env,2)
        env(:,iA) = abs(hilbert(A.data.beam_mf_in_time(:,iA)));
        if sm_len==1
            env_sm(:,iA) = env(:,iA);
        else
            env_sm(:,iA) = smooth(env(:,iA),sm_len);
        end
    end
    env_sm = env_sm(1:sm_len:end,:);


    % Get plotting params
    range_beam_sm = A.data.range_beam(1:sm_len:end);
    [amesh,rmesh] = meshgrid(A.data.polar_angle,range_beam_sm);
    [X,Y] = pol2cart(amesh/180*pi,rmesh);

    % Echo level calibration
    total_gain_crd_coh = A.param.gain_load -...
        A.param.gain_sys -...
        A.param.gain_beamform -...
        A.param.gain_pc;

    % Plot
    fig = figure('position',[280 60 800 560]);
    subplot(121)
    h1 = pcolor(X/1e3,Y/1e3,20*log10(env_sm)+...
                total_gain_crd_coh-3);
    hold on
    set(h1,'edgecolor','none');
    axis equal
    colormap(jet)
    caxis([65 95])
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    title(['Ping ', num2str(iP)])

    subplot(122)
    h1 = pcolor(X/1e3,Y/1e3,20*log10(env_sm_accum)+...
                total_gain_crd_coh-3);
    hold on
    set(h1,'edgecolor','none');
    axis equal
    colormap(jet)
    caxis([65 95])
    axis(axis_lim)
    xlabel('Distance (km)','fontsize',14)
    ylabel('Distance (km)','fontsize',14)
    set(gca,'fontsize',12)
    title('Averaged ping')
    %    end

end



if 0
    % Plotting
    %     fig = figure('position',[280 60 800 560]);
    %     corder = get(gca,'colororder');
    figure(fig)
    suptitle(title_text)
    
    h_ori = plot_small_echogram_raw(subplot(121),A,sm_len,ori_caxis,axis_lim);
    caxis([65 95])
    colorbar('Ticks',65:10:95,'location','southoutside')
    set(gca,'fontsize',12,'xtick',-4.3:1:-1.3,'ytick',-4.5:1:-1.5);
    axis([-4.3 -1.3 -4.5 -1.5]);
    xlabel('Distance (km)','fontsize',16)
    ylabel('Distance (km)','fontsize',16)
    set(gca,'layer','top')

    % Get normalizer output
    plot_normalized_echogram(subplot(122),beamform_norm,meta,norm_param,norm_caxis,axis_lim);
    tt = title(sprintf('sm%d, aux%dm, guard%d',...
                       norm_param.sm_len,norm_param.aux_m, ...
                       norm_param.guard_num_bw));
    set(tt,'fontsize',12);
    caxis([5 15])
    colorbar('Ticks',5:2:15,'location','southoutside');
    set(gca,'fontsize',12,'xtick',-4.3:1:-1.3,'ytick',-4.5:1:-1.5);
    axis([-4.3 -1.3 -4.5 -1.5]);
    xlabel('Distance (km)','fontsize',16)
    ylabel('Distance (km)','fontsize',16)
    set(gca,'layer','top')
    
    saveas(fig,fullfile(save_path,[save_fname,'.fig']),'fig');
    epswrite(fullfile(save_path,[save_fname,'.eps']));
    saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'.png']),...
        'format','png');
    
%     % bw version
%     colormap(brewermap([],'Greys'))
%     epswrite(fullfile(save_path,[save_fname,'_bw.eps']))
%     saveSameSize_150(gcf,'file',fullfile(save_path,[save_fname,'_bw.png']),...
%         'format','png');

    end




