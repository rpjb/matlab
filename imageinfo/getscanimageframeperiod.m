% GETSCANIMAGEFRAMEPERIOD Identifies the period between frames in seconds for
% a ScanImage stack
%
% getscanimageframeperiod looks within the image description header of the image
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


function frameperiod = getscanimageframeperiod(folder)

%% debugging
folder = '/Users/rpjb/Desktop/JC_GO_NOGO/11202013';

tiffiles = FindFiles(folder,'.*\.tif',1);
datafile = [tiffiles(1).path filesep tiffiles(1).name];

x =imfinfo(datafile);
imgdesc = x(1).ImageDescription;
hdr.fastZEnable = regexp(imgdesc,'scanimage.SI4.fastZEnable = ([0-9.]+)','tokens');
hdr.fastZEnable = str2num(char(hdr.fastZEnable{1}));

if ~hdr.fastZEnable % single stack
    hdr.scanFramePeriod = regexp(imgdesc,'scanimage.SI4.scanFramePeriod = ([0-9.]+)','tokens');
    frameperiod = str2num(char(hdr.scanFramePeriod{1}));
else % multi z-stack
    hdr.fastZPeriod = regexp(imgdesc,'scanimage.SI4.fastZPeriod = ([0-9.]+)','tokens');
    frameperiod = str2num(char(hdr.fastZPeriod{1}));
end

if ~isnumeric(frameperiod)
	disp('no frameperiod found')
	frameperiod = [];
end