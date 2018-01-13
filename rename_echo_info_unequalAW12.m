% 2018 01 13  Rename all folders echo_info_run* and
%             echo_info_run*_img from 2017 to *_unequalAW12

base_path = '~/internal_2tb/trex/figs_results';

folders = dir(fullfile(base_path,filesep,'echo_info_run*'));

for iF=1:length(folders)
    ori_name = folders(iF).name;
    run_num = ori_name(14:16);
    if length(ori_name)>16
        new_name = sprintf('unequalAW12_echo_info_run%s_img',run_num);
    else
        new_name = sprintf('unequalAW12_echo_info_run%s',run_num);
    end
    disp(['Changing ',ori_name, ' to ', new_name]);
    
    [status,message,~] = movefile(fullfile(base_path,ori_name),...
                                  fullfile(base_path,new_name));

    if status==0
        disp(message)
        break;
    end
    
end

