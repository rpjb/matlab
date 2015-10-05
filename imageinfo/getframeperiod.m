% GETFRAMEPERIOD Identifies the period between frames in seconds for a
% Prairie T-stack
%
% getframeperiod looks within the configuration files of the TSeries
% acquisition folder and extracts frame times established by the imaging
% dwell times.
%
% type: function
%
% inputs:
%   folder: absolute path to the TSeries folder
%
% outputs: 
%   frameperiod: period in seconds
%
% dependencies:
%   parseprairie
%   findfiles
%
% Robert Barretto, robertb@gmail.com
% 07/29/2011 2:54pm

function frameperiod = getframeperiod(folder)

configfile = FindFiles(folder,'TSeries-\d{8}-\d{4}-\d{3}Config.cfg',1);
if isempty(configfile)
    disp('config file not found')
    frameperiod =[];
    return
end
temp = parseprairie([configfile.path,filesep,configfile.name],{'framePeriod'});
frameperiod = temp{1};
