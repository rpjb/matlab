function [DisplayFigure] = pruner(in_file,output_folder)
% start miji
StartMiji;
import ij.*

%%%%%%%%%%%%%%%%
% main figure 
%%%%%%%%%%%%%%%%
DisplayFigure = figure;
set(DisplayFigure,'Units','centimeters')
set(DisplayFigure,'Name','Subset Manager','NumberTitle','off')
set(DisplayFigure,'Toolbar','none')

% set display position depending on mac or pc
if ismac
    set(DisplayFigure,'position',[5 8.5 4 7.5])
else
    set(DisplayFigure,'position',[5 2.5 4 7.5])
end

%%%%%%%%%%%%%%%%
% initialization
%%%%%%%%%%%%%%%%

% close imagej windows
CloseImageJWindows;

% open image
if isstruct(in_file) % if a list of files
    MIJ.run('Image Sequence...',['open=[' in_file(1).path '] sort']);
else % or a single file
    MIJ.run('Open...', ['path=[' in_file ']']);
end


% initializes parameters
subsetinfo.x = [];
subsetinfo.y = [];
subsetinfo.t = [];


%%%%%%%%%%%%%%%%
% status display 
% status update
%%%%%%%%%%%%%%%%
StatusText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(StatusText,'String','Current Status','Units','centimeters');
set(StatusText,'Position',[.5 .5 3.5 1.5]);
set(StatusText,'ButtonDownFcn',@StatusClick);
    function [] = StatusClick(~,~)
        disp('manual stop')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keyboard button for debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ManualButton = uicontrol(DisplayFigure,'Style','PushButton');
set(ManualButton,'String','keyboard','Units','centimeters');
set(ManualButton,'Callback',@ManualFcn);
set(ManualButton,'Position',[.5 3.5 2 0.5]);
    % function for popping up keyboard
    function [] = ManualFcn(~,~)
        keyboard
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reopen button 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ReopenButton = uicontrol(DisplayFigure,'Style','PushButton');
set(ReopenButton,'String','reopen','Units','centimeters');
set(ReopenButton,'Callback',@ReopenFcn);
set(ReopenButton,'Position',[.5 4.5 2 0.5]);
    % function for popping up keyboard
    function [] = ReopenFcn(~,~)
		% close imagej windows
		CloseImageJWindows;
		% open image
        if isstruct(in_file) % if a list of files
            MIJ.run('Image Sequence...',['open=[' in_file(1).path '] sort']);
        else % or a single file
            MIJ.run('Open...', ['path=[' in_file ']']);
        end

		set(CropButton,'Enable','on')    	
		set(ShortenButton,'Enable','on')    	
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% crop button 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CropButton = uicontrol(DisplayFigure,'Style','PushButton');
set(CropButton,'String','crop xy','Units','centimeters');
set(CropButton,'Callback',@CropFcn);
set(CropButton,'Position',[.5 5.5 2 0.5]);
    % function for popping up keyboard
    function [] = CropFcn(~,~)
    	pts = MIJ.getRoi(0);
    	subsetinfo.x = [pts(1,1) pts(1,2)];
    	subsetinfo.y = [pts(2,1) pts(2,4)];
        ij.IJ.runMacro('nSlices');        
        numslices = ij.IJ.getLog;
        pause(.2);
        ij.IJ.run('Close')
        subsetinfo.t = [1 str2num(char(numslices))];
    	MIJ.run('Crop');
		set(CropButton,'Enable','off')    	
		UpdateInfo
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shorten button 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ShortenButton = uicontrol(DisplayFigure,'Style','PushButton');
set(ShortenButton,'String','shorten','Units','centimeters');
set(ShortenButton,'Callback',@ShortenFcn);
set(ShortenButton,'Position',[.5 6.5 2 0.5]);
    % function for popping up keyboard
    function [] = ShortenFcn(~,~)
    	pts = MIJ.getRoi(0);
    	subsetinfo.x = [pts(1,1) pts(1,2)];
    	subsetinfo.y = [pts(2,1) pts(2,4)];

		MIJ.run('Make Substack...');
		tempstr = char(MIJ.getCurrentTitle);
		d = regexp(tempstr,'\d+','match');
		subsetinfo.t = [str2num(d{1}), str2num(d{2})];
		set(ShortenButton,'Enable','off')    	
		UpdateInfo
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save button 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SaveButton = uicontrol(DisplayFigure,'Style','PushButton');
set(SaveButton,'String','save','Units','centimeters');
set(SaveButton,'Callback',@SaveFcn);
set(SaveButton,'Position',[.5 2.5 2 0.5]);
    % function for popping up keyboard
    function [] = SaveFcn(~,~)        
        % name base directory 

        
        
        if isstruct(in_file) % if original file is a set of tifs
            temp_file = fullfile(in_file(1).path,in_file(1).name);
            foldernames = strsplit(temp_file,filesep);
            [folder, filename, ~] = fileparts(temp_file); 
        else % if original file is a single file (in_file is an absolute path)
            foldernames = strsplit(in_file,filesep);
            [folder, filename, ~] = fileparts(in_file); 
        end
        subfolder = foldernames{end-1};
        newsubfolder = [subfolder '_x' num2str(subsetinfo.x(1)) '-' num2str(subsetinfo.x(2)) 'y' num2str(subsetinfo.y(1)) '-' num2str(subsetinfo.y(2)) 't' num2str(subsetinfo.t(1)) '-' num2str(subsetinfo.t(2))];
               
        % create destination for subinfo.mat
        folder = strrep(folder,subfolder,newsubfolder);
        if ~exist(folder)
            mkdir(folder);
        end
        subsetinfo_file = fullfile(folder,'subset_info.mat');

        % create destination for .tif subset file
        output_file = fullfile(folder,filename);
        if ispc % hotfix for imagej syntax for filesep
            output_file = strrep(output_file,filesep,[filesep filesep]);
        end

        % create destination for info.mat
        out_folder = strrep(output_folder,subfolder,newsubfolder);
        suboutput_folder = out_folder;
        if ~exist(suboutput_folder)
            mkdir(suboutput_folder);
        end

        % save info file
        masterinfo = fullfile(output_folder,'info.mat');
        copyfile(masterinfo,suboutput_folder);
        % save subset info file
        save(subsetinfo_file,'subsetinfo');
		% save within imageJ
		ij.IJ.runMacro(['saveAs("Tiff","' output_file ,'")']);
    end

function [] = UpdateInfo()
	if isempty(subsetinfo.x)
		infostr{1} = ' ';
	else
		infostr{1} = ['x: ' num2str(subsetinfo.x(1)) '-' num2str(subsetinfo.x(2))];
	end
	if isempty(subsetinfo.y)
		infostr{2} = ' ';
	else
		infostr{2} = ['y: ' num2str(subsetinfo.y(1)) '-' num2str(subsetinfo.y(2))];
	end
	if isempty(subsetinfo.t)
		infostr{3} = ' ';
	else
		infostr{3} = ['frames: ' num2str(subsetinfo.t(1)) '-' num2str(subsetinfo.t(2))];
	end	
	set(StatusText,'String',infostr)
end

end