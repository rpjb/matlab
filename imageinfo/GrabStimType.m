% GrabStimType Identifies the imaging stimulation parameters for Lindsey
% datasets on Olympus XYZT microscope
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
% 03/03/2015 12:29pm


function info = GrabStimType(output_file)

% load lindsey stimulation table
% assume the file is in the matlab path, so do not have to give the
% absolute path
lm_file = 'lmstim.xls';
A = importdata(lm_file);

% create output_file location
% output_file = fullfile(output_folder,'info.mat');
[output_folder,~,~] = fileparts(output_file);

% load output file if exists
if exist(output_file)
    temp=load(output_file);
    if isfield(temp,'info')
        info = temp.info;
    end
end
    

%% assume this is lindsey's data

% determine tastant timings from the folder
% extract the date from Lindsey's folder names
t = regexp(output_folder,'.*(\d{6}).*','tokens');
datasetid = t{1};
datematches = strcmp(A.textdata.tastants(:,1),datasetid);

    % initially set the tastant program to the first match
    tastantnum = find(datematches);
    if sum(datematches) == 0
        % the file folder might have been named YYMMDD instead of MMDDYY
        newdatasetid = datasetid{1}([3 4 5 6 1 2]);
        datematches = strcmp(A.textdata.tastants(:,1),newdatasetid);
        tastantnum = find(datematches);        
        if sum(datematches) == 0        
            disp(['stimulation protocols not found for dataset: ' char(datasetid)])
            return
        end        
    end
    tastantnum = tastantnum(1);

    % these are simple rules to address lindsey's duplicates
    if sum(datematches) > 1
        if strcmp(datasetid,'092314')
            xm = strfind(output_file,'bud');
            if isnumeric(num2str(output_file(xm+4)))
                budnum = num2str(output_file(xm+4));
            else
                budnum = num2str(output_file(xm+3));
            end
            if xm <= 4
                tastantnum = 34;
            else
                tastantnum = 35;
            end
        end
        if strcmp(datasetid,'092614')
            xm = strfind(output_file,'bud');
            if isnumeric(num2str(output_file(xm+4)))
                budnum = num2str(output_file(xm+4));
            else
                budnum = num2str(output_file(xm+3));
            end
            if xm <= 3
                tastantnum = 37;
            else
                tastantnum = 38;
            end
        end                  
    end

    programname = A.data.tastants(tastantnum,1);
    programnum = find(A.data.programs(:,1) == programname);
    info.stim.types = A.textdata.tastants(tastantnum,4:10);
    info.stim.onsets = A.data.programs(programnum,3:9);
    info.stim.duration = A.data.programs(programnum,10); 
    info.version = '0.55';

% save info.mat
save(output_file,'info');



