% GrabImgType Identifies the imaging stack parameters 
%
% StartMiji adds the Fiji.app scripts folder to the Java path. In case it has 
% already been added, or previously started, it looks for the MIJ class in 
% the existing workspace.
%
% info.mat is created and stored in the input_folder for future processing
%
% type: function
%
% inputs:
%   input_folder:  string specifying the folder containing the image
%   output_folder: string specifying the folder to save info.mat 
%   
% outputs:
%   info:  structure containing found parameters
%
% dependencies:
%   
%
% Robert Barretto, robertb@gmail.com
% 02/16/2015 6:12pm


function info = GrabImgType(input_folder, output_folder)
% example input folders for debugging purposes 
% example epifluorescence stack
%input_folder = '/Volumes/USB 2/original gut data/01-16-15/acetate after frame 100_1';
% example epifluorescence multi-tif stack
%input_folder = '/Volumes/USB 2/original gut data/01-30-15/2 - isovaleric acid_1';
% example prairie two photon stack
%input_folder = '/Volumes/USB 2/imaging data/20141009-01 enac ai32/TSeries-10092014-1151-001';
% example olympus 4d stack
%input_folder = '/Users/rpjb/Desktop/ck14 lindsey';

% create output_file location
output_file = fullfile(output_folder,'info.mat');
% load output file if exists
if exist(output_file)
    temp=load(output_file);
    if isfield(temp,'info')
        info = temp.info;
    end
end
info.version = '0.11';

% determine dataset type
if ~isempty(dir([input_folder filesep '*.cfg']))
    % prairie two photon has a cfg and xml file
    info.type = 'prairie';    
    info.img.period = getframeperiod(input_folder);
    
elseif ~isempty(dir([input_folder filesep 'metadata.txt']))
    % epi multi-tif has a metadata.txt file
    info.type = 'epi multi-tif';
    info.img.period = getepiframeperiod(input_folder);

elseif ~isempty(dir([input_folder filesep '*.txt']))
    % olympus 
    info.img.period = getolympusframeperiod(input_folder);
    info.img.stackdepth = getolympusstackdepth(input_folder);
    % decipher whether XYT or XYZT
    info.type = ['olympus' getolympusstacktype(input_folder)];
else 
    % epi single-tif
    info.type = 'epi single-tif';
    info.img.period = getepiframeperiod(input_folder);

end

% % can remove this snippet when you know info.mat are rolled up properly
% % some datasets have already been aligned
% if isfield(temp,'aligndata')
%     info.align.method = 'matlab_native';
%     info.align.tform = temp.aligndata.tform;
%     info.align.referenceimage = temp.aligndata.referenceimage;
% end

save(output_file,'info')

