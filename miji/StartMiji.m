% StartMiji Loads Miji (ImageJ) for Matlab 
%
% StartMiji adds the Fiji.app scripts folder to the Java path. In case it has 
% already been added, or previously started, it looks for the MIJ class in 
% the existing workspace.
%
% If there are errors from this function, it mostly requires the user to add
% their path Fiji.app/scripts to the if/else statements to correctly locate
% their Fiji installation.
%
% type: function
%
% inputs: none
%   
% outputs: none
%
% dependencies:
%   Miji
%
% Robert Barretto, robertb@gmail.com
% 02/16/2015 5:02pm

function [ output_args ] = StartMiji()
if ~exist('MIJ','class')
    if ismac        
        addpath('/Applications/Fiji.app/scripts')
    elseif ispc
        if exist('C:\Users\rpjb\My Dropbox\matlab\Fiji.app\scripts')
            addpath('C:\Users\rpjb\My Dropbox\matlab\Fiji.app\scripts')
        else
            addpath('C:\Users\rpjb\Dropbox\matlab\Fiji.app\scripts')
        end
    end
    Miji;
end

end

