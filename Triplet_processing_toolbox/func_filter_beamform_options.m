function [Pro_ParameterPCompress beamform_option] = func_filter_beamform_options

choice = questdlg('Do you want to process data with theoretical-sourcce-wave-pulse-compression?',...
                  'Option to filter or pulse compress',...
                  'With Pulse Compression','Only filtering','With Pulse Compression')
% Handle response
switch choice
    case 'With Pulse Compression'
        Pro_ParameterPCompress =1;
    case 'Only filtering'
        Pro_ParameterPCompress =0;
end

choice2 = questdlg('Do you want to beamform data?',...
                   'Option to beamform or not',...
                   'Beamform', 'No beamform','Beamform')

switch choice2
    case 'Beamform'
        beamform_option =1;
    case 'No beamform'
        beamform_option =0;
end


