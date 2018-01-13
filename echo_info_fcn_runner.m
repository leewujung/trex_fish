% 2017 02 22  Gather and plot all summary echo info
% 2018 01 13  Run echo_info_fcn in batch

run_num_all = [79,87,94,103,115,120,124];

base_data_path = '~/internal_2tb/trex/figs_results/';
base_save_path = '~/internal_2tb/trex/figs_results/';
plot_show_opt = 1;

for iR=1:length(run_num_all)
    if ismember(run_num_all(iR),[79,87,94])
        switch run_num_all(iR)
          case 79
            ping_num = 4:9:877;    % run 79
            wfm = 4;
            data_path = 'subset_beamform_cardioid_coherent_run079';
          case 87
            ping_num = 1:1:1000;   % run 87
            wfm = 1;
            data_path = 'subset_beamform_cardioid_coherent_run087';
          case 94
            ping_num = 3:3:899;    % run 94
            wfm = 3;
            data_path = 'subset_beamform_cardioid_coherent_run094';
        end
        echo_info_fcn(data_path,ping_num,base_save_path,base_data_path,plot_show_opt);
    else
        switch run_num_all(iR)
          case 103
            ping_num1 = 3:5:911;    % run 103
            ping_num2 = 5:5:911;    % run 103
            wfm1 = 3;
            wfm2 = 5;
            data_path = 'subset_beamform_cardioid_coherent_run103';
          case 115
            ping_num1 = 1:2:926;    % run 115
            ping_num2 = 2:2:926;    % run 115
            wfm1 = 1;
            wfm2 = 2;
            data_path = 'subset_beamform_cardioid_coherent_run115';
          case 120
            ping_num1 = 1:2:513;    % run 120
            ping_num2 = 2:2:513;    % run 120
            wfm1 = 1;
            wfm2 = 2;
            data_path = 'subset_beamform_cardioid_coherent_run120';
          case 124
            ping_num1 = 1:2:973;    % run 124
            ping_num2 = 2:2:973;    % run 124
            wfm1 = 1;
            wfm2 = 2;
            data_path = 'subset_beamform_cardioid_coherent_run124';
          case 131
            ping_num1 = 1:2:1000;    % run 131
            ping_num2 = 2:2:1000;    % run 131
            wfm1 = 1;
            wfm2 = 2;
            data_path = 'subset_beamform_cardioid_coherent_run131';
        end
        echo_info_fcn(data_path,ping_num1,base_save_path,base_data_path,plot_show_opt);
        echo_info_fcn(data_path,ping_num2,base_save_path,base_data_path,plot_show_opt);
    end
end

