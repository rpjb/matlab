% quick way to get stimulus types

function info = GrabEpiStimType(output_file)

% create output_file location
% output_file = fullfile(output_folder,'info.mat');
% load output file if exists

if exist(output_file)
    temp=load(output_file);
    if isfield(temp,'info')
        info = temp.info;
    end
end
    
% info file
info.stim.types = {'30 AceK', '5 Qui', '60 NaCl','100 MPG / 2 IMP','50 CA','water','500 sucrose'};

info.stim.onsets = [6.5 21.5 36.5 51.5 66.5 81.5 96.5];

info.stim.duration = 2;

info.version = '0.55';

% save info
save(output_file,'info');