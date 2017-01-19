function [Roll_T1,Roll_T2,Heading_T1,Heading_T2,GLAT,GLON,sample_freq,sample_time_ms, tot_data] = ...
          func_load_raw_FORA_data_wjlee(pathname, all_datafiles, nsig) %, TripInUseChn0,TripInUseDtChn,TripInUseChn1)

%   This function loads in raw FORA data. All info including acoustics data
%   is saved in the structure array called "out". Reconstruct all necessary
%   info from "out".
%
% 2016/06/16  WJL: take out t_start/t_end to load in all data
%                  take out TripInUseChn stuff

data_filename  = all_datafiles(nsig).name;
full_pathname = fullfile(pathname, data_filename);

[gn,gm] = find(data_filename=='.');
outpt_name =  data_filename(1:(max(max(gn),max(gm))-1));

out = read_sac_real_gzx(full_pathname,'TRIP'); % 2016/06/16 WJL: take out t_start/t_end
% out = read_sac_real_gzx(full_pathname,'TRIP',[t_start t_end]); % Read data t_start to t_end seconds!

% % % % % %out structure for data read from the data file selected
% %               date: 'Fri'
% %               time: 'Apr'
% %         Julian_day: 1
% %             samp_f: 12500
% %               GLAT: 30.0599
% %               GLON: -85.6811
% %     fout_fwd_twist: 0
% %     fout_aft_twist: 319.5681
% %     out.fout_fwd_heading;
% %     out.fout_aft_heading;
% %             t_s: [234x110592 int32]
% %            t_axis: [1x110592 double]
% % % % % changed from the original Matlab code, add ROLL parameter
% % % % %  (fout_fwd_twist fout_aft_twist) and  GPS parameter (GLAT GLON)
% % % % %   and heading infeormaton(fout_fwd_heading fout_aft_heading)
% % % % %  t_s is set as data type LONG(int32) to save memory

Roll_T1 = out.fout_fwd_twist;
Roll_T2 = out.fout_aft_twist;
Heading_T1 = out.fout_fwd_heading;
Heading_T2 = out.fout_aft_heading;
GLAT    = out.GLAT;
GLON    = out.GLON;

sample_freq = out.samp_f;
[gn1,gn2] = size( out.t_s);  % 2016/06/16 WJL
% [gn1,gn2] = size( out.t_s([TripInUseChn0:TripInUseDtChn:TripInUseChn1],:));
% out.t_s = out.t_s([TripInUseChn0:TripInUseDtChn:TripInUseChn1],:);

sample_time_ms = out.t_axis(1,:)*1000;

[gn1,gn2] = size( out.t_s(:,:));
tot_data=[];clear tot_data;
tot_data(:,:) = double(reshape(out.t_s,gn1,gn2));


