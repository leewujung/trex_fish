% 2016/06/28  Split-window normalizer
%             re. Fialkawski & Gauss 2010, IEEE JOE
% 2017/02/06  Revise to work with new data format
%             make it a function

run_num = 131;
base_path = '~/internal_2tb/trex/figs_results/';
data_path_mf = sprintf('subset_beamform_cardioid_coherent_run%d',run_num);
ping_num = 150;


% Loop through pings
fig_both = figure('position',[50,80,1200,550]);
for ping_num=ping_num_all

    file_mf = sprintf('%s_ping%04d.mat',...
                      data_path_mf,ping_num);
    mf = load(fullfile(base_path,data_path_mf,file_mf));


    % Set auxilliary and guard band length
    r_len_m = diff(mf.data.range_beam(1:2));    % step size for r_win in [m]
    t_len_sec = diff(mf.data.t(1:2));  % step size for t_win in [sec]

    aux_m = 200;  % range for auxilliary band [m]
    aux_pt = floor(aux_m/r_len_m);

    guard_num_bw = 2;  % number of 1/BW for guard band
    guard_pt = ceil(guard_num_bw*mf.tx_sig.tau/t_len_sec);

    slide_win_pt = 1+2*guard_pt+2*aux_pt;  % [pt]
    trim = guard_pt+aux_pt;  % [pt];
    slide_idx = -trim:trim;
    aux_idx = [-trim+(0:aux_pt-1),guard_pt+1:trim];

    title_text_orig = sprintf('Run %d, ping %04d, original',...
                              run_num,ping_num);
    title_text_norm = sprintf('Run %d, ping %04d, Guard band %d/BW, Aux band %d m',...
                              run_num,ping_num,guard_num_bw,aux_m);
    save_fname = sprintf('%s_run%03d_ping%04d_guard%02d_aux%03d',...
                         script_name,run_num,ping_num,...
                         guard_num_bw,aux_m);
    
    % Get mf output magnitude squared
    sm_len = 100;
    mf_sq = zeros(size(mf.data.beam_mf_in_time));
    mf_sq_sm = zeros(size(mf.data.beam_mf_in_time));
    for iB = 1:size(mf.data.beam_mf_in_time,2)
        mf_sq(:,iB) = abs(hilbert(mf.data.beam_mf_in_time(:,iB))).^2;
        mf_sq_sm(:,iB) = smooth(mf_sq(:,iB),sm_len);
    end
    mf_sq_sm = mf_sq_sm(1:sm_len:end,:);

    % Get idx
    r_len_m = diff(mf.data.range_beam(1:2))*sm_len;    % step size for r_win in [m]
    t_len_sec = diff(mf.data.t(1:2))*sm_len;  % step size for t_win in [sec]

    aux_m = 200;  % range for auxilliary band [m]
    aux_pt = floor(aux_m/r_len_m);

    guard_num_bw = 2;  % number of 1/BW for guard band
    guard_pt = ceil(guard_num_bw*mf.tx_sig.tau/t_len_sec);

    slide_win_pt = 1+2*guard_pt+2*aux_pt;  % [pt]
    trim = guard_pt+aux_pt;  % [pt];
    slide_idx = -trim:trim;
    aux_idx = [-trim+(0:aux_pt-1),guard_pt+1:trim];

    % Normalization
    want_idx = trim+1:size(mf_sq_sm,1)-trim;
    beamform_norm = zeros(size(mf_sq_sm));

    for iS=want_idx
        norm_fac = mean(mf_sq_sm(iS+aux_idx,:),1);
        beamform_norm(iS,:) = mf_sq_sm(iS,:)./norm_fac;
    end

    % Get X,Y locations
    [amesh,rmesh] = meshgrid(mf.data.polar_angle,mf.data.range_beam(1:sm_len:end));
    [X,Y] = pol2cart(amesh/180*pi,rmesh);


end % loop through pings



