% StartMiji Loads Miji (ImageJ) for Matlab 
%
% StartMiji adds the Fiji.app scripts folder to the Java path. In case it has 
% already been added, or previously started, it looks for the MIJ class in 
% the existing workspace.
%
% On the first use on a foreign machine, StartMiji asks for the scripts 
% directory within Fiji.app.  After providing this, StartMiji saves that location
% and automatically loads it on subsequent iterations.
%
% type: function
%
% inputs: none
%   
% outputs: none
%
% dependencies:
%   Miji (within Fiji.app installation)
%
% Robert Barretto, robertb@gmail.com
% 04/07/2015 4:26pm

function [ output_args ] = StartMiji()

if ~exist('MIJ','class') % execute if MIJ is not already loaded
    % for Robert's machines this is hardcoded
    if ismac
        if exist('/Applications/Fiji.app/scripts')         
            addpath('/Applications/Fiji.app/scripts');
            Miji;
            return
        end
    elseif ispc
        if exist('C:\Users\rpjb\My Dropbox\matlab\Fiji.app\scripts')
            addpath('C:\Users\rpjb\My Dropbox\matlab\Fiji.app\scripts')
            Miji;
            return
        elseif exist('C:\Users\rpjb\Dropbox\matlab\Fiji.app\scripts')
            addpath('C:\Users\rpjb\Dropbox\matlab\Fiji.app\scripts')
            Miji;
            return
        end
    end

    % for a vanilla machine save a location within the StartMiji path
    % find path of StartMiji
    abspath = which('StartMiji');
    folder = fileparts(abspath);
    % look if a stored mijilocation exists
    fname = fullfile(folder,'mijilocation.mat');
    if ~exist(fname)
        % user display to select Miji location
        mijipath = uigetdir(pwd,'Select the directory containing Miji scripts');    
        if mijipath==0
            mijipath = '';
            disp('nothing selected')
            return
        end
        % save Miji path for future use
        save(fname,'mijipath');       
        addpath(mijipath);
        Miji;
        
    else % load an existing configuration
        temp = load(fname);
        mijipath = temp.mijipath;
        addpath(mijipath);
        Miji;

    end

end

end