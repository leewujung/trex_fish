function [F1, F2, PL, Taper] = func_extract_signal_info(nsig, allsignal_info)

space_ind = find( allsignal_info(nsig,:) == ' ' );
waveform_name = allsignal_info(nsig,1:space_ind(1)-1);
waveform_amp = allsignal_info(nsig,space_ind(1)+1 : space_ind(2)-1);
rep_no = allsignal_info(nsig,space_ind(2)+1 : space_ind(3)-1);
digit_timesec = allsignal_info(nsig,space_ind(3)+1 : space_ind(4)-1);
delay_timems = allsignal_info(nsig,space_ind(4)+1 : end);

underscore_ind = find( waveform_name == '_' );
F1 = str2num(waveform_name(underscore_ind(3)+1:underscore_ind(4)-1));
F2 = str2num(waveform_name(underscore_ind(5)+1:underscore_ind(6)-1));
PL = str2num(waveform_name(underscore_ind(6)+3:underscore_ind(7)-1));
Taper = str2num(waveform_name(underscore_ind(7)+2:underscore_ind(7)+6));


