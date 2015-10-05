% PARSEPRAIRIE Extracts desired parameters from a T-Series stack
%
% parseprairie opens the xml file of interest, and does a text scan to
% identify specified parameters.  this function has only been used for
% T-Series acquisitions.
%
% common parameters include:
%   pixelsPerLine
%   framePeriod
%   fullImagePixelsPerLine
%   
% type: function
%
% inputs:
%   configfile: absolute path to desired cfg file
%   parameters: cell array consisting of desired XML tags
%
% outputs:
%   values: cell array containing values for each parameter; if the
%     parameter does not exist, then a prompt is displayed and an empty
%     cell is returned in that array position
%
% Robert Barretto, robertb@gmail.com
% 06/17/2011 12:06pm
% rev 1.01 - increased specificity of parser by inserting '"' around the parameter

function [values] = parseprairie(configfile, parameters)

%% open xml information
fid = fopen(configfile);
data = textscan(fid,'%s','delimiter','\n');
data = data{1};
fclose(fid);
%% parse times for each stack acquisition
% if 1 == 0
%     imagefields = regexp(data,['relativeTime="(\d+\.?\d*)'],'tokens');
%     temp = [];
%     for i = 1:length(imagefields)
%         if isempty(imagefields{i})==0
%             temp = [temp; str2num(char(imagefields{i}{:}))];
%         end
%     end
%     imagetimes = temp;
% end
%% parse arbitrary values if needed

for b = 1:length(parameters) 
    % search for parameter and value line by line
    imagefields = regexp(data,['"' parameters{b} '"' '(?:.+)value="(\d+\.?\d*)"'],'tokens');
    if isempty([imagefields{:}]) % check if parameter exists in config file
        disp([parameters{b} ' does not exist'])
        values{b} = {};
    else 
        i = 1; output = [];
        while isempty(output) && i < length(data)
            if isempty(imagefields{i}) == 0
                output = str2num(char(imagefields{i}{:}));
            end
            i=i+1;
        end
        values{b} = output;
    end
end
