% AlignImageStabilizer Uses the ImageJ ImageStabilizer plugin to align a tif stack.
%
% alignimagestabilizer uses Miji and ij libraries to run the ImageStabilizer plugin.
%
% type: function
%
% inputs: 
%   input_file - absoulute path to the unaligned single TIF stack
%
% outputs: none
%   output_file - absolute path to the alignted single TIF stack
%
% dependencies:
%   Miji
%
% Robert Barretto, robertb@gmail.com
% 03/29/2015 9:12pm



function outputdata = AlignImageStabilizer(input_file, output_file)


% import Miji and imagej library
StartMiji;
import ij.*

% open file in imagej
if isstruct(input_file)
    MIJ.run('Image Sequence...',['open=[' input_file(1).path '] sort']);
else
    MIJ.run('Open...', ['path=[' input_file ']']);
end

% alignment with first image
MIJ.run('ImageStabilizer register');


% grab Transformation text window and close
[~, fname, ~] = fileparts(input_file);

% if there is a space in the filename --
spots = findstr(fname,' ');
if isempty(spots)
    imagejname = fname;
else    
    imagejname = fname(1:(spots(1)-1));
end

IJ.selectWindow([imagejname '.log'])

temp = IJ.runMacro('getInfo');
temp = IJ.getLog;
IJ.selectWindow([imagejname '.log'])
MIJ.run('Close')

IJ.selectWindow('Log')
MIJ.run('Close')

% parse transformation info
lines = temp.split('\n'); %split by line breaks

cline = '1'; startind=1;
while ~strcmp(cline,'0')    
    cline = char(lines(startind));
    startind = startind+1;
end

for i=startind:length(lines)
    cline = char(lines(i));
    temp = textscan(cline,'%f,%f,%f,%f');    
    out(i-startind+1,1) = temp{1}; % slice number
    out(i-startind+1,2) = temp{2}; % scaling factor?
    out(i-startind+1,3) = temp{3}; % x?
    out(i-startind+1,4) = temp{4}; % y?        
end
tformdata = out;

% grab reference image
tempimage = MIJ.getImage([fname '.tif']);
referenceimage = squeeze(tempimage(:,:,1));







% format tformdata into consistent matrix


% save aligned data
IJ.selectWindow(['Stablized ' imagejname]);
IJ.saveAs('Tiff',output_file)
MIJ.run('Close');

IJ.selectWindow([fname '.tif']);
MIJ.run('Close');

% output data
outputdata.tform = tformdata;
outputdata.referenceimage = referenceimage;

end

