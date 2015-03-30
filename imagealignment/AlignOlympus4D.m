function tformdata = AlignOlympus4D(input_file, output_file)

% input_file = '/Users/rpjb/Desktop/ck14 lindsey/stack1_0001.tif';
% output_file = '/Users/rpjb/Desktop/aligned/ck14 lindsey/aligned.tif';

% load info file
[basedir,basename,basetype] = fileparts(output_file);
info_file = fullfile(basedir,'info.mat');
temp = load(info_file);
info = temp.info;

% import Miji and imagej library
StartMiji;
import ij.*

interval = info.img.stackdepth;

imginfo = imfinfo(input_file);
w = imginfo(1).Width;
h = imginfo(1).Height;
numframes = length(imginfo);

try
    numtimes = numframes/interval;
    if numtimes<1
        numtimes = 1;
        interval = numframes;
    end
    catch
    numtimes = 1;
    interval = numframes;
end
% setup var to save data
maxframe = uint16(zeros(h,w,numtimes));
tempframe = uint16(zeros(h,w,interval));
for i=1:numtimes
    disp(i)
    % calculate frames to use
    offset = (i-1)*interval;
    for j = 1:interval
        startframe = offset+ j;
        tempframe(:,:,j) = imread(input_file,startframe);        
    end
    MIJ.createImage(tempframe);
    MIJ.run('StackReg','transformation=[Translation]');
    if numtimes == 1
        maxframe = max(MIJ.getImage('Import from Matlab'),[],3);
    else
        maxframe(:,:,i) = max(MIJ.getImage('Import from Matlab'),[],3);
    end
    MIJ.run('Close')
end
% align flattened stack

MIJ.createImage(uint16(maxframe));



% save aligned data
[basedir,basename,basetype] = fileparts(output_file);
if ~exist(basedir)
    mkdir(basedir)
end
IJ.saveAs('Tiff',output_file);
disp('saved first')




% MIJ.run('StackReg','transformation=[Translation]');
% 
% % prep for registration with first image
% pause(5)
% MIJ.run('Turboreg prep');
% MIJ.run('Collect Garbage');
% pause(5)
% disp('prep')
% MIJ.run('Turboreg register');
% 
% disp('register')
% MIJ.run('Kalman OldStack Filter','acquisition_noise=0.05 bias=0.80');
% MIJ.run('Close')
% IJ.saveAs('Tiff',fullfile(basedir,'fullaligned.tif'));
% disp('saved second')
% 
% keyboard
MIJ.run('Close');