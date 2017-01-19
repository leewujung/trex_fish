%Added number of sensors line to read sbf format for input to xdemod
function out = read_sac_real_gzxjust3Second(filename, array_select,t_lim)

%%%%%%%%%%%%%%data Type selection
valid = {'ULF'; 'LF'; 'MF'; 'HF'; 'TRIP'; 'AFT_TRIP'; 'FWD_TRIP'; 'OMNI'};
idx = strcmpi(array_select, valid);
matches = 0;
for i = 1:size(idx, 1)
    if idx(i)
        matches = matches + 1;
    end
end

if (matches ~= 1)
 temp = [' *** Error invalid argument: ', array_select];
 disp(temp); 
 temp = [' *** usage: select_fora_subarray_version2(Input, Select)'];
 disp(temp); 
 temp = [' *** where'];
 disp(temp); 
 temp = [' *** Input is the filename of the FORA output file either Version 0 or 1.'];
 disp(temp); 
 temp = [' *** Select is one of the following:'];
 for i = 1:size(idx, 1)
   temp = [temp, ' '];
   temp = [temp, valid{i}];
 end
 disp(temp); 
 return;
end


%
% Open input file.
%
  filediemessage = dir(filename);
  
  [fid, message] = fopen(filename, 'r');
  if fid == -1
     temp = [' *** Error opening input file: ', filename];
     disp(temp);
     temp = [' *** Error Message = ', message];
     disp(temp);
     return;
  end

% % %   
% % % 
% % % [fid, message] = fopen(filename, 'r');
% % % if fid == -1
% % %      fprintf(2, '%s\n', message)
% % %      return
% % % end

if nargin < 3
  t_lim = [];
end


%
% Obtain header information.
%
  mode = 0;
  version = 0;
  ncha_fwd_trip = 0;
  while 1
     s = fscanf(fid, '%c', 80);
     disp(s);
%      findstr(s(1:6), 'TIME');
     if strncmp(s, 'END', 3)
          break
     elseif findstr(s(1:6), 'TIME')
          out.date = sscanf(s,'%*s %s',1);
          out.time = sscanf(s,'%*s %*s %s',1);
     elseif findstr(s(1:6), 'JDAY')
          out.Julian_day = sscanf(s,'%*s %d',1);
     elseif findstr(s(1:6), 'RECL')
          RECL = sscanf(s, '%*s %f', 1);
     elseif findstr(s(1:6), 'NRHE')
          NRHE = sscanf(s, '%*s %f', 1);
     elseif findstr(s(1:6), 'FOUT')
          out.samp_f = sscanf(s, '%*s %f', 1);
     elseif findstr(s(1:6), 'NCHA')
          number_of_sensors = sscanf(s, '%*s %f', 1);
     elseif findstr(s(1:6), 'DSIZE')
          dsize = sscanf(s, '%*s %f', 1);
          nsamples_per_read = dsize;
          
%     elseif strncmp(s, 'AZIM', 4)
%          fscanf(fid, '%s', 1);
%          out.azim = fscanf(fid, '%f', number_of_sensors);
%     elseif strncmp(s, 'ELEV', 4)
%          fscanf(fid, '%s', 1);
%          out.elev = fscanf(fid, '%f', number_of_sensors);
     elseif strfind(s, 'NAS1 ')
           temp = sscanf(s, '%*s %f %f %f', [1,3]);
           out.fout_fwd_twist = temp(3);
           out.fout_fwd_heading = temp(2);           
     elseif strfind(s, 'NAS2 ')
           temp = sscanf(s, '%*s %f %f %f', [1,3]);
           out.fout_aft_twist = temp(3);
           out.fout_aft_heading = temp(2);           
     elseif strfind(s, 'GLAT ')        
           out.GLAT =  sscanf(s, '%*s %f', 1);
     elseif strfind(s, 'GLON ')
           out.GLON =  sscanf(s, '%*s %f', 1);
     end     
     
%      offset = ftell(fid);
%      s = fscanf(fid, '%c', 80);
%      disp(s);
% 
%      if (strncmp(s, 'END', 3) == 1)
%           break;
%      elseif strfind(s, 'TIME ')
%           in_date = sscanf(s,'%*s %s',1);
%           in_time = sscanf(s,'%*s %*s %s',1);
%      elseif strfind(s, 'JDAY ')
%           Julian_day = sscanf(s,'%*s %d',1);
%      elseif strfind(s, 'RECL ')
%           RECL = sscanf(s, '%*s %f', 1);
%      elseif strfind(s, 'NRHE ')
%           NRHE = sscanf(s, '%*s %f', 1);
%      elseif strfind(s, 'FOUT ')
%           samp_f = sscanf(s, '%*s %f', 1);
%           fout_offset = offset;
%      elseif strfind(s, 'NCHA ')
%           number_of_sensors = sscanf(s, '%*s %f', 1);
%           ncha_offset = offset;
%      elseif strfind(s, 'DSIZE ')
%           dsize = sscanf(s, '%*s %f', 1);
%           nsamples_per_read = dsize;
%           dsize_offset = offset;
%      elseif strfind(s, 'V1_MODE ')
%           mode = sscanf(s, '%*s %d', 1);
%           mode_offset = offset;
%      elseif strfind(s, 'V1_VERSION ')
%           version = sscanf(s, '%*s %d', 1);
%           version_offset = offset;
%      elseif strfind(s, 'V1_NCHA_FWD_TRIP ')
%            ncha_fwd_trip = sscanf(s, '%*s %d', 1);
%            ncha_fwd_trip_offset = offset;
%      elseif strfind(s, 'V1_NCHA_AFT_TRIP ')
%            ncha_aft_trip = sscanf(s, '%*s %d', 1);
%            ncha_aft_trip_offset = offset;
%      elseif strfind(s, 'V1_DSIZE_FWD_TRIP ')
%            dsize_fwd_trip = sscanf(s, '%*s %d', 1);
%            dsize_fwd_trip_offset = offset;
%      elseif strfind(s, 'V1_DSIZE_AFT_TRIP ')
%            dsize_aft_trip = sscanf(s, '%*s %d', 1);
%            dsize_aft_trip_offset = offset;
%      elseif strfind(s, 'V1_FOUT_FWD_TRIP ')
%            fout_fwd_trip = sscanf(s, '%*s %d', 1);
%            fout_fwd_trip_offset = offset;
%      elseif strfind(s, 'V1_FOUT_AFT_TRIP ')
%            fout_aft_trip = sscanf(s, '%*s %d', 1);
%            fout_aft_trip_offset = offset;
%      elseif strfind(s, 'NAS1 ')
%            temp = sscanf(s, '%*s %f %f %f', [1,3]);
%            fout_fwd_twist = temp(3);
%            fout_fwd_twist_offset = offset;
%      elseif strfind(s, 'NAS2 ')
%            temp = sscanf(s, '%*s %f %f %f', [1,3]);
%            fout_aft_twist = temp(3);
%            fout_aft_twist_offset = offset;
%      end
     %%%code may be added here to get roll Heading  and Gps And some information  else. 
% % % % % % % get triplet roll sensor readings using 'more datafile.dat'; roll_1 is 3rd value 
% % % % % % % after NAS1 (T1); roll_2 is 3rd value after NAS2 (T2). 
% % % % % % % check against logs for errors!!
% % % % % % % If needed, create trip sensor position file from Newfora_spv_trip(T1,T2)
% % % % % % % and save as Newfora_spv_trip-roll1-roll2.  
% % % % % % % Create linear sensor position files from Newfora_spv and save as
% % % % % % % Newfora_spv_(aperture) eg. as Newfora_spv_hf etc.
% % % % % % % 

  end



  if (version == 0)
      if ((strcmpi(array_select,'AFT_TRIP') == 1) || (strcmpi(array_select,'FWD_TRIP') == 1))
         temp = [' *** Error old file format does not support: ', array_select];
         disp(temp);
         fclose(fid);
         return; 
      end
  else
      if ((strcmpi(array_select,'AFT_TRIP') == 0) && (strcmpi(array_select,'FWD_TRIP') == 0))
         temp = [' *** Unexpected File Format for: ', array_select];
         disp(temp);
         fclose(fid);
         return; 
      end
  end
%
% Rewind file, and read in header block.  
% Rewrite value for number of channels in file from 160 to 64.
% Note that header locations 328, 329, and 330 correspond to 160.
% Character value for 1 = 49, 6 = 54, and 0 = 48.
% Change to value to 64 by setting 6 = 54, 4 = 52, and BLANK = 0.
%
  fseek (fid,0,-1);
  header = fread(fid, NRHE*RECL, 'char');
% % % %   if (version == 0)
% % % %       if (strcmpi(array_select,'OMNI') == 1)
% % % %          header(328) = 50;
% % % %          header(329) = 0;
% % % %          header(330) = 0;
% % % %       elseif (strcmpi(array_select,'TRIP') == 0)
% % % %          header(328) = 54;
% % % %          header(329) = 52;
% % % %          header(330) = 0;
% % % %       end
% % % %   end
% Loop over total file.
%

NumSampPerCh = floor((filediemessage.bytes - NRHE*RECL)/number_of_sensors/4);

out.t_s=zeros(number_of_sensors,NumSampPerCh,'int32');



 
  icount = 1;
  
  while 1
%
% Read all data into 'outtemp' array.
%
    if (version == 0)
        inp = fread(fid, [nsamples_per_read, number_of_sensors], 'long');
        if (feof(fid))
          disp(icount-1);
          break;
        end
    else
%         if (strcmpi(array_select,'AFT_TRIP') == 1)
%              dump = fread(fid, [dsize_fwd_trip, ncha_fwd_trip], 'long');
%             if (feof(fid))
%               disp(icount-1);
%               break; 
%             end
%             inp = fread(fid, [dsize_aft_trip, ncha_aft_trip], 'long');
%             if (feof(fid))
%               disp(icount-1);
%               break;   
%             end
%        else
%             inp = fread(fid, [dsize_fwd_trip, ncha_fwd_trip], 'long');
%             if (feof(fid))
%               disp(icount-1);
%               break; 
%             end;
%             dump = fread(fid, [dsize_aft_trip, ncha_aft_trip], 'long');
%             if (feof(fid))
%               disp(icount-1);
%               break; 
%             end
%        end
    end
    inp = inp';
%
% Start writing out subaperture data, depending on user selection.
% 

    if (strcmpi(array_select,'HF') == 1)
      for iloop = 1:64
         outtemp(iloop,:) = inp (34+iloop,:);
      end
%       size(out);
    elseif (strcmpi(array_select,'MF') == 1)
      for iloop = 1:16
         outtemp(iloop,:) = inp(18+iloop,:);
      end
      instart = 35;
      outstart = 17;
      for iloop = 0:31 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+1,:),1);
         instart = instart+2;
      end
      instart = 99;
      outstart = 49;
      for iloop = 0:15
         outtemp(outstart+iloop,:) = inp(instart+iloop,:);
      end
%       size(out);
    elseif (strcmpi(array_select,'LF') == 1)
      for iloop = 1:16
         outtemp(iloop,:) = inp(2+iloop,:);
      end
      instart = 19;
      outstart = 17;
      for iloop = 0:7 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+1,:),1);
         instart = instart+2;
      end
      instart = 35;
      outstart = 25;
      for iloop = 0:15 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+3,:),1);
         instart = instart+4;
      end
      instart = 99;
      outstart = 41;
      for iloop = 0:7 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+1,:),1);
         instart = instart+2;
      end
      instart = 115;
      outstart = 49;
      for iloop = 0:15
         outtemp(outstart+iloop,:) = inp(instart+iloop,:);
      end
%       size(out);
    elseif (strcmpi(array_select,'ULF') == 1)
      instart = 3;
      outstart = 1;
      for iloop = 0:7 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+1,:),1);
         instart = instart+2;
      end
      instart = 19;
      outstart = 9;
      for iloop = 0:3 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+3,:),1);
         instart = instart+4;
      end
      instart = 35;
      outstart = 13;
      for iloop = 0:7 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+7,:),1);
         instart = instart+8;
      end
      instart = 99;
      outstart = 21;
      for iloop = 0:3 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+3,:),1);
         instart = instart+4;
      end
      instart = 115;
      outstart = 25;
      for iloop = 0:7 
         outtemp(outstart+iloop,:) = mean(inp(instart:instart+1,:),1);
         instart = instart+2;
      end
      outtemp(33:64,:) = inp(131:162,:);
    elseif (strcmpi(array_select,'TRIP') == 1)
      nchan_out = 234;
      outtemp(1:234,:) = inp(1:234,:);
    elseif (strcmpi(array_select,'OMNI') == 1)
      nchan_out = 2;
      for iloop = 1:2
         outtemp(iloop,:) = inp(iloop,:);
      end
    elseif (strcmpi(array_select,'FWD_TRIP') == 1)
      nchan_out = 90;
      outtemp(1:nchan_out,:) = inp(1:nchan_out,:);
    elseif (strcmpi(array_select,'AFT_TRIP') == 1)
      nchan_out = 144;
      outtemp(1:nchan_out,:) = inp(1:nchan_out,:);
    else
      disp('*** ERROR: Invalid Subarray Selection... Choose ULF, LF, MF, HF, TRIP, AFT_TRIP, FWD_TRIP or OMNI... Exiting...***');
      return;
    end
%
% Set array selection data to output data structure.
%     fwrite(fout_id, out, 'long');
% dsize
    out.t_s(:,(icount-1)*nsamples_per_read+[1:nsamples_per_read]) = outtemp;
    icount=icount+1;
    
% % %add for time limit data reading ,just to save our time % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
    if isempty(t_lim)
    else
        if( icount*nsamples_per_read > out.samp_f*max(t_lim))
            break;
        end
    end  
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     

  end
  

  fclose(fid);
[gn,gm] = size(out.t_s);
if isempty(t_lim)
     out.t_axis = (0:size(out.t_s, 2)-1)/out.samp_f;
else
     lim = round(out.samp_f*t_lim)+1;
     out.t_s = out.t_s(:,lim(1):min(lim(2),gm));
     out.t_axis = (0:size(out.t_s, 2)-1)/out.samp_f;
end  

