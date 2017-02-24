% 2017 02 22  Gather and plot all summary echo info

run_num_all = [79,87,94,103,115,120,124,131];

for iR=1:length(run_num_all)
    if ismember(run_num_all(iR),[79,87,94])
        switch run_num_all(iR)
          case 79
            ping_num = 4:9:877;    % run 79
            wfm = 4;
          case 87
            ping_num = 1:1:1000;   % run 87
            wfm = 1;
          case 94
            ping_num = 3:3:899;    % run 94
            wfm = 3;
        end
        summarize_run_fcn(run_num_all(iR),ping_num,wfm,1);
    else
        switch run_num_all(iR)
          case 103
            ping_num1 = 3:5:911;    % run 103
            ping_num2 = 5:5:911;    % run 103
            wfm1 = 3;
            wfm2 = 5;
          case 115
            ping_num1 = 1:2:926;    % run 115
            ping_num2 = 2:2:926;    % run 115
            wfm1 = 1;
            wfm2 = 2;
          case 120
            ping_num1 = 1:2:513;    % run 120
            ping_num2 = 2:2:513;    % run 120
            wfm1 = 1;
            wfm2 = 2;
          case 124
            ping_num1 = 1:2:973;    % run 124
            ping_num2 = 2:2:973;    % run 124
            wfm1 = 1;
            wfm2 = 2;
          case 131
            ping_num1 = 1:2:1000;    % run 124
            ping_num2 = 2:2:1000;    % run 124
            wfm1 = 1;
            wfm2 = 2;
        end
        summarize_run_fcn(run_num_all(iR),ping_num1,wfm1,1);
        summarize_run_fcn(run_num_all(iR),ping_num2,wfm2,2);
    end
end

