% GETOLYMPUSSTACKTYPE Identifies the stack type for an Olympus T-Stack 
%
% getolympusstacktype looks within the image description header of the image
% file and extracts the stack type
%
% type: function
%
% inputs:
%   folder: absolute path to the image folder
%
% outputs: 
%   stacktype: string 'XYZT' or 'XYT'
%
% dependencies:
%   FindFiles
%
% Robert Barretto, robertb@gmail.com
% 03/29/2015 4:28pm


function stacktype = getolympusstacktype(folder)

txtfiles = FindFiles(folder,'.*\.txt',1);
datafile = [txtfiles.path filesep txtfiles.name];

fileid = fopen(datafile);
expression = '"Scan Mode"	"([A-Z]+)"';

    i = 1;
    while 1==1
       lineout = fgetl(fileid);
       if isnumeric(lineout)
           break
       end      
       [tokens, ~] = regexp(lineout,expression,'tokens','match');
       if ~isempty(tokens)
        stacktype = char(tokens{1}{1});
        return
       end
    end
disp('stack type not found')
stacktype = [];
    