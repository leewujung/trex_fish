function [waveform_name waveform_amp Nrep digit_timesec delay_timems allsignal_info] = func_read_ECF(full_pathname);

fid_dat = fopen(full_pathname, 'r');

count = 0;
sig_count = 0;
while ~ feof(fid_dat)
    
    read_ecf = fgetl(fid_dat);
    if (length(read_ecf) > 1 )
        if (read_ecf(1) ~= '%')
            count = count + 1;
            % Retrieve info from each line of the ECF file, format as follows
            % Waveform Filename, Waveform Amplitude (Volts Peak), Transmission Repeat Count,
            %    Digitization Time(secs), Transmission Delay (secs)
            ecf_info = read_ecf;
            space_ind = find( ecf_info(:) == ' ' );
            waveform_name = ecf_info(1:space_ind(1)-1);
            waveform_amp = ecf_info(space_ind(1)+1 : space_ind(2)-1);
            Nrep = ecf_info(space_ind(2)+1 : space_ind(3)-1);
            digit_timesec = ecf_info(space_ind(3)+1 : space_ind(4)-1);
            delay_timems = ecf_info(space_ind(4)+1 : end);
            % Put info for every ping into a big matrix with N repetitions
            for nrep = 1:str2num(Nrep)
                sig_count = sig_count + 1;
                allsignal_info(sig_count,:) = sprintf([waveform_name,' ',waveform_amp,' %4.4d ',digit_timesec,' ',delay_timems],nrep);
            end
        end
    end
end