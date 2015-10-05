% GrabPrairieStimType Identifies the imaging stimulation parameters for Lindsey
% datasets on Prairie microscope
%
% Stimulation info is created and stored in the info.mat structure. Note
% that you need to update the location of the lmstim.xls file
%
% type: function
%
% inputs:
%   output_folder: string specifying the folder to load/save info.mat 
%   
% outputs:
%   info:  structure containing found parameters
%
% dependencies:
%   
%
% Robert Barretto, robertb@gmail.com
% 07/29/2015 12:29pm


function info = GrabPrairieStimType(output_file)

% create output_file location
% output_file = fullfile(output_folder,'info.mat');
[output_folder,~,~] = fileparts(output_file);

% load output file if exists
if exist(output_file)
    temp = load(output_file);
    if isfield(temp,'info')
        info = temp.info;
    end
end
    

%% assume this is lindsey's data

    info.stim.types = {'AceK 30mM', 'Qui 5mM', 'NaCl 60mM', 'MPG/IMP 100/2mM', 'CA 50mM', 'Cyx 0.1mM', 'sucrose 300mM'};
    info.stim.onsets = [6.5 21.5 36.5 51.5 66.5 81.5 96.5];
    info.stim.duration = 2; 
    info.version = '0.55';

% save info.mat
save(output_file,'info');



