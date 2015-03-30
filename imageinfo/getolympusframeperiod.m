% GETOLYMPUSFRAMEPERIOD Identifies the period between frames in seconds for
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


function frameperiod = getolympusframeperiod(folder)

%% debugging
%folder = '/Users/rpjb/Desktop/ck14 lindsey';

txtfiles = FindFiles(folder,'.*\.txt',1);
datafile = [txtfiles.path filesep txtfiles.name];

fileid = fopen(datafile);
expression = '"T Dimension"	"([0-9]+), ([0-9]+.[0-9]+) - ([0-9]+.[0-9]+)';

    i = 1;
    while 1==1
       lineout = fgetl(fileid);
       if isnumeric(lineout)
           break
       end      
       [tokens, ~] = regexp(lineout,expression,'tokens','match');
       if ~isempty(tokens)
        frameperiod = (str2num(char(tokens{1}{3}))-str2num(char(tokens{1}{2})))/str2num(char(tokens{1}{1}));
        return
       end
    end

disp('no frameperiod found')
frameperiod = [];
    