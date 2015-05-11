% PREPFIGURE prepares figures for printable output.
%
% prepfigure converts several properties automatically.
%  
% type: function
%
% inputs:
%   fig: handle for print figure
%   figdim: two element vector for figure dimensions in centimeters
%       (e.g. [width height])
%
% outputs:
%   outputfig: handle for print figure
%
% dependencies on custom functions: none
%
% Robert Barretto, robertb@gmail.com
% 09/09/2013    

function [outputfig] = prepfigure(fig,figdim)
    %set default font
    set(0,'defaultAxesFontName', 'Arial');
    set(0,'defaultAxesFontSize', 10);
    set(0,'defaultTextFontName', 'Arial');
    set(0,'defaultTextFontSize', 10);

    % set main properties of figure
    set(fig,'Units','centimeters')
    set(fig,'Color',[1 1 1]);
    set(fig, 'Toolbar', 'none');
    set(fig, 'Resize','off')

    % set size of 
    pos = get(fig,'Position');
    set(fig,'Position',[pos(1), pos(2), figdim(1), figdim(2)])
    
    % set printing properties of figure
    % setting to auto centers diagram to the printed pdf size
    set(fig, 'PaperPositionMode', 'auto');
    set(fig, 'PaperUnits', 'centimeters');
    set(fig, 'PaperSize',[figdim(1)+2 figdim(2)+2])

    
    % output variable to provide access to figure
    outputfig = fig;
end

