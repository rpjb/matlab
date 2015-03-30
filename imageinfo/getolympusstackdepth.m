% GETOLYMPUSSTACKDEPTH Identifies the period between frames in seconds for
% an Olympus T-Stack 
%
% getepiframeperiod looks within the image description header of the image
% file and extracts frame times established by the imaging
% dwell times.
%
% type: function
%
% inputs:
%   folder: absolute path to the image folder
%
% outputs: 
%   frameperiod: period in seconds
%
% dependencies:
%   FindFiles
%
% Robert Barretto, robertb@gmail.com
% 02/11/2015 1:35pm


function stackdepth = getolympusstackdepth(folder)

txtfiles = FindFiles(folder,'.*\.txt',1);
datafile = [txtfiles.path filesep txtfiles.name];

fileid = fopen(datafile);
expression = '"Z Dimension"	"([0-9]+)';

    i = 1;
    while 1==1
       lineout = fgetl(fileid);
       if isnumeric(lineout)
           break
       end      
       [tokens, ~] = regexp(lineout,expression,'tokens','match');
       if ~isempty(tokens)
        stackdepth = str2num(char(tokens{1}{1}));
        return
       end
    end

disp('no stackdepth found')
stackdepth = [];
    