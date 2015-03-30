% GETEPIFRAMEPERIOD Identifies the period between frames in seconds for a
% Micromanager T-stack
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
%   findfiles
%
% Robert Barretto, robertb@gmail.com
% 02/05/2015 12:20pm

function frameperiod = getepiframeperiod(folder)


% folder = '/Users/rpjb/Dropbox/project - calcium imaging analysis/krebs wash_1';
% imagingfile = FindFiles(folder,'.*\.tif',1);
%folder = '/Volumes/USB 2/01-30-15/2 - isovaleric acid_1';

imagingfile = FindFiles(folder,'.*\.tif',1);

if length(imagingfile) == 1
    a = imfinfo([imagingfile.path,filesep,imagingfile.name]);    
    % grab elapsed time for each frame
    % skip the first frame because its image description is different from the
    % subsequent frames
    for i = 2:length(a)
        expression = '"ElapsedTime-ms":([0-9]+)';
        [tokens, ~] = regexp(a(i).UnknownTags(1).Value,expression,'tokens','match');
        out(i) = str2num(char(tokens{1}));
    end
    % take the median of the actual frame periods and convert to milliseconds
    frameperiod = median(diff(out))/1000;
    disp(frameperiod)
    
elseif length(imagingfile) > 1
    imagingdata = FindFiles(folder,'metadata.txt',1);
    fileid = fopen([imagingdata.path,filesep,imagingdata.name]);
    expression = '"ElapsedTime-ms": ([0-9]+)';  
    i = 1;
    while 1==1
       lineout = fgetl(fileid);
       if isnumeric(lineout)
           break
       end           
       [tokens, ~] = regexp(lineout,expression,'tokens','match');
       if ~isempty(tokens)
        out(i) = str2num(char(tokens{1}));
        i = i+1;
       end
    end
    frameperiod = median(diff(out))/1000;
    disp(frameperiod)
else
    frameperiod = '';
    disp('files not found')
end