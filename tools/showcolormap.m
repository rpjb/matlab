% showcolormap Visualizes a colormap.
%
% showcolormap calculates and displays an RGB colormap
%
% type: script
%
% inputs:
%    
% outputs:
%
% dependencies on custom functions:
%   none
%
% Robert Barretto, robertb@gmail.com
% 04/07/15 5:25pm cleanup

function [DisplayFigure] = showcolormap(varargin)

if nargin == 0
	% create a basic colormap if no input
	numbits = 256;
	cmap = gray(numbits);
	cmap(:,1) = 1;
	cmap = flipud(cmap);
else
	cmap = varargin{1};
	numbits = size(cmap,1);  
end

% create an image
cimg = zeros([numbits numbits 3]);

for i = 1:numbits % for each row
    for j=1:3 % for each color
        cimg(i,:,j) = cmap(i,j);
    end
end

% display image
DisplayFigure = figure;
imshow(cimg);