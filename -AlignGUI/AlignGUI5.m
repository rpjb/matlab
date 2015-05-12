% AlignGUI5 Visual interface to align images, and optionally, identify 
% cellular ROIs.
% 
% AlignGUI5 is a frontend for aligning large batches of files. It allows
% the user to select from several alignment routines.
%
% type: function
%
% inputs: 
%  varargin usage:
%    AlignGUI5  -- user prompt for input and output folder
%    AlignGUI5(output_folder)
%    AlignGUI5(input_folder, output_folder)
%
% outputs:
%  none
% 
% dependencies on custom functions:
%  FindFolders 
%  findjobj
%  AlignMatlab
%  AlignOlympus4D
%  AlignTurboReg
%  AlignTurboRegTranslation
%  FindFiles
%  GrabImgType
%  imreadtiffstack
%  playmovie
%  FastFindTransients
%  GrabStimType
%  leadingnum2str
%  prepfigure
%  StartMiji  
%
% Robert Barretto, robertb@gmail.com
% 04/07/2015 3:40pm

function [ready] = AlignGUI5(varargin)

% handle various inputs
nargin = length(varargin);
switch nargin
    case 0
        % user display to select original image folder
        input_folder = uigetdir(pwd,'Select the directory containing original images (optional)');    
        if input_folder==0
            filepath = '';
            input_folder = '';
        end
        % user display to select aligned image folder
        output_folder = uigetdir(pwd,'Select the directory containing aligned images and info data (required)');    
        if isnumeric(output_folder)
            disp('Output path required. Exiting.')
            return
        end
    case 1
        % if provided one 'debug' then default to below folder
        if strcmp('debug',varargin{1})
            if ismac
                input_folder = '/Users/rpjb/desktop/test imaging data';
                output_folder = '/Users/rpjb/desktop/test aligned data';
            else
                input_folder = 'G:\research\columbia research\taste bud imaging\set 1 sorted';
                output_folder = 'G:\research\columbia research\taste bud imaging\set 1 aligned';    
            end
        % if provided only the output folder    
        else
            % user only provides the aligned data folder
            input_folder = '';
            output_folder = varargin{1};            
        end
    case 2        
        % user provides original data and aligned data folder
        input_folder = varargin{1};
        output_folder = varargin{2};
    otherwise
        disp('Input arguments not understood. Exiting.')
        return
end

% create figure display
close all
DisplayFigure = figure;
set(DisplayFigure,'Units','centimeters')
set(DisplayFigure,'Name','Image Manager','NumberTitle','off')
set(DisplayFigure,'Toolbar','none')

% set display position depending on mac or pc
if ismac
    set(DisplayFigure,'position',[5 8.5 24.5 22])
else
    set(DisplayFigure,'position',[5 2.5 24.5 22])
end
    
%%%%%%%%%%%%%%%%
% status display 
% status update
%%%%%%%%%%%%%%%%
StatusText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(StatusText,'String','Current Status','Units','centimeters');
set(StatusText,'Position',[.5 10 10 0.5]);
set(StatusText,'ButtonDownFcn',@StatusClick);
statusclick = 0;
    function [] = StatusClick(~,~)
        statusclick = 1;
        disp('manual stop')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keyboard button for debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ManualButton = uicontrol(DisplayFigure,'Style','PushButton');
set(ManualButton,'String','keyboard','Units','centimeters');
set(ManualButton,'Callback',@ManualFcn);
set(ManualButton,'Position',[.5 11 2 0.5]);
    % function for popping up keyboard
    function [] = ManualFcn(~,~)
        keyboard
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display for main directories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OriginalLocationLabel = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(OriginalLocationLabel,'BackgroundColor',[.8 .8 .8])
set(OriginalLocationLabel,'String','Original Data Folder ','Units','centimeters');
set(OriginalLocationLabel,'Position',[.5 16 4 .5]);

OriginalLocationText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(OriginalLocationText,'String','','Units','centimeters');
set(OriginalLocationText,'Position',[.5 15 10 .6])

AlignedLocationLabel = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(AlignedLocationLabel,'BackgroundColor',[.8 .8 .8])
set(AlignedLocationLabel,'String','Aligned Data Folder','Units','centimeters');
set(AlignedLocationLabel,'Position',[.5 14 4 .5]);

AlignedLocationText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(AlignedLocationText,'String','','Units','centimeters');
set(AlignedLocationText,'Position',[.5 13 10 .6])

% update folder display
set(OriginalLocationText,'String',input_folder);
set(AlignedLocationText,'String',output_folder);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create file table display
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% locate folder contents 
if ~isempty(input_folder)
    imagingsets = FindFolders(input_folder,'.*.',2);
else
    imagingsets = '';
end
imagingoutputsets = FindFolders(output_folder,'.*.',2);
% if input folder is not available, but output folder is
% must mean that data is procesed into aligned files
% and present the datasets
if isempty(imagingsets) && ~isempty(imagingoutputsets)
    input_folder = output_folder;
    imagingsets = imagingoutputsets;
end
filedata = cell(length(imagingsets),3);
rowstoremove = zeros(length(imagingsets),1);

for i=1:length(imagingsets)  
    % skip if a main folder
    if strcmp(imagingsets(i).path,input_folder)
        rowstoremove(i) = 1;
        continue
    end 
    % command line loading progress update
    if rem(i,10) == 0
        disp(['Loading ' num2str(i) ' of ' num2str(length(imagingsets)) ' images'])
    end

    % populate fields for FileTable

    % populate folder field
    filedata{i,1} = imagingsets(i).path((length(input_folder)+2):end);
    % populate trial field
    filedata{i,2} = imagingsets(i).name;   
    % populate file path field (construct info.mat and .tif path)
    inputpath = fullfile(imagingsets(i).path,imagingsets(i).name,'info.mat');
    outputimagingset = strrep(imagingsets(i).path,input_folder,output_folder);
    filedata{i,9} = fullfile(outputimagingset,imagingsets(i).name,'info.mat');
    outputpath = fullfile(outputimagingset,imagingsets(i).name,'*.tif');

% can remove this.  need to decide when in workflow we should initialize
% info variable
%     % populate "info file exist" field
%     info = GrabImgType(fullfile(imagingsets(i).path,imagingsets(i).name),fullfile(outputimagingset,imagingsets(i).name) );

    % is there an info file in the output directory
    infopath = filedata{i,9};
    if exist(infopath)>0        
        % populate info exists path
        filedata{i,3} = true;
        temp = load(infopath); 
        info = temp.info;
        % populate info version field
        filedata{i,5} = info.version;
% can remove this snippet when you know info.mat are rolled up properly
        % info.align.method = 'olympus4d';
        % save(infopath,'info');
        if isfield(info,'cells')
            if isfield(info.cells,'numcells') & info.cells.numcells>0
% can remove this snippet when you know info.mat are rolled up properly
%                 % quick debug fix to remove NaN celltraces
%                 questionablecellcontours = squeeze(sum(sum(info.cells.cellcontours>0,1),2))==0;
%                 questionablecelltraces = cellfun( @(x)(sum(isnan(x)) == length(x)),info.cells.celltrace)';
%                 indicestoremove = questionablecellcontours & questionablecelltraces;
% 
%                 if sum(indicestoremove)>0
%                     info.cells.cellcontours(:,:,indicestoremove) = [];
%                     info.cells.celltrace(indicestoremove) = []; 
%                     info.cells.numcells = info.cells.numcells - sum(indicestoremove);
%                 end
%                 save(infopath,'info');

                % populate number of cells counted field
                filedata{i,6} = info.cells.numcells;                
            end
        end
        % set values of Stack and Qaulity

        % populate isstack and isquality fields
        filedata{i,7} = false;
        filedata{i,8} = false;
        if isfield(info,'metadata')
            if isfield(info.metadata,'isstack')
                filedata{i,7} = info.metadata.isstack;
            end
            if isfield(info.metadata,'manualcheck')
                filedata{i,8} = info.metadata.manualcheck;
            end
        end
    else
        filedata{i,3} = false;        
        filedata{i,5} = '0';
    end
    % populate "align file exist" field
    % is there a tif file in the output directory
    if length(dir(outputpath))>0
        filedata{i,4} = true;
    else
        filedata{i,4} = false;
    end
end
filedata(logical(rowstoremove),:) = [];



columnname = {'Folder','Trial','Info','Aligned','Version','Cells','Stack','Quality','File Path'};
columnformat = {'char','char','logical','logical','char','numeric','logical','logical','char'};
columneditable = [false false false false false false true true false];
columnwidth = {150 100 50 50 40 40 40 40 200};
selecteddata = [];
FileTable = uitable('Units','centimeters','Position',[.5 .5 23.5 9],...
    'Data',filedata,'ColumnName',columnname,...
    'ColumnFormat',columnformat,'ColumnEditable',columneditable,...
    'RowName',[],'CellSelectionCallback',@SelectFile,...
    'ColumnWidth',columnwidth,'CellEditCallback',@ChangeValue);

% matlab/java hack to update contents of uitable without resetting the position
jscroll = findjobj(FileTable);
jtable = jscroll.getViewport.getComponent(0);

    % function for popping up keyboard
    function [] = SelectFile(~,eventdata)
        selecteddata = eventdata.Indices;
    end
    % function for changing cell value
    function [] = ChangeValue(~,eventdata)
        switch eventdata.Indices(2)
            case 7
                row = eventdata.Indices(1);
                % modify info
                info = LoadInfoFile(row);
                if ~isempty(filedata{row,7})
                    if filedata{row,7} == true 
                        filedata{row,7} = false;
                        info.metadata.isstack = false;
                    else
                        filedata{row,7} = true;
                        info.metadata.isstack = true;
                    end
                else
                    filedata{row,7} = true;
                    info.metadata.isstack = true;
                end
                % update uitable (old way)
                % set(FileTable,'Data',filedata);                
                % update uitable
                jtable.setValueAt(filedata{row,7},row-1,7-1)
                SaveInfoFile(info,row)

            case 8
                row = eventdata.Indices(1);
                % modify info
                info = LoadInfoFile(row);
                if ~isempty(filedata{row,8})
                    if filedata{row,8} == true 
                        filedata{row,8} = false;
                        info.metadata.manualcheck = false;
                    else
                        filedata{row,8} = true;
                        info.metadata.manualcheck = true;
                    end
                else
                    filedata{row,8} = true;
                    info.metadata.manualcheck = true;
                end
                % update uitable (old way)
                % set(FileTable,'Data',filedata);                
                % update uitable
                jtable.setValueAt(filedata{row,8},row-1,8-1)
                SaveInfoFile(info,row)

            otherwise
                return
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create aligning interface
AlignPanel = uipanel('Title','Alignment Panel','Units','centimeters','Position',[12 12 5 8.5],'BackgroundColor',[.8 .8 .8]);
AlignOption = uibuttongroup('Title','Method','Parent',AlignPanel,'Units','centimeters','Position',[.5 2 4 4.5],'BackgroundColor',[.8 .8 .8]);
u0 = uicontrol('Units','centimeters','Style','radiobutton','String','Matlab',...
    'pos',[0.15 2.50 3.5 0.5],'parent',AlignOption,'Enable','on');
u1 = uicontrol('Units','centimeters','Style','radiobutton','String','Turboreg rigidbody',...
    'pos',[0.15 1.75 3.5 0.5],'parent',AlignOption,'Enable','on');
u2 = uicontrol('Units','centimeters','Style','radiobutton','String','Image Stabilizer',...
    'pos',[0.15 1.00 3.5 0.5],'parent',AlignOption,'Enable','on');
u3 = uicontrol('Units','centimeters','Style','radiobutton','String','4D stack',...
    'pos',[0.15 0.25 3.5 0.5],'parent',AlignOption,'Value',1);
u4 = uicontrol('Units','centimeters','Style','radiobutton','String','Turboreg translation',...
    'pos',[0.15 3.25 3.5 0.5],'parent',AlignOption,'Value',1);

% if the input_folder has no raw data, disable the align panel
if strcmp(input_folder,'')
    set(AlignPanel,'Visible','on')
end


AlignButton = uicontrol('Parent',AlignPanel,'Style','PushButton');
set(AlignButton,'String','Align Files','Units','centimeters');
set(AlignButton,'Callback',@AlignFunction);
set(AlignButton,'Position',[.5 .5 3 1]);

currentfiledata = [];
    function [] = AlignFunction(~,~)
        % temp holder updates the status window on alignment technique used
        currentalignoption = get(get(AlignOption,'SelectedObject'),'String');        
        set(StatusText,'String',currentalignoption);
        
        % check if selected data
        if isempty(selecteddata)
            set(StatusText,'String','no datasets selected');
            return
        end
    
        % identify imaging sets to process 
        localselecteddata = selecteddata;
        numselected = size(localselecteddata,1);
        for i=1:numselected
            % update status string
            set(StatusText,'String',[num2str(i) ' of ' num2str(numselected)])
            pause(.5)
            
            row = localselecteddata(i,1);
            currentfiledata = filedata{row,:};            
            align_in_folder = fullfile(input_folder, filedata{row,1}, filedata{row,2});
            align_out_folder = fullfile(output_folder, filedata{row,1}, filedata{row,2});

            % if align_out_folder doesn't exist make it
            if ~exist(align_out_folder)
                mkdir(align_out_folder)
            end
            
            % create info structure
            info = GrabImgType(align_in_folder, align_out_folder);
            % identify files
            temp = FindFiles(align_in_folder,'.*.tif',1);
            if length(temp)>1
                in_file = temp;
                out_file = fullfile(align_out_folder,'aligned.tif');
            else
                in_file = fullfile(align_in_folder, temp.name);
                [~,fname,~] = fileparts(in_file);
                out_file = fullfile(align_out_folder,[fname '.tif']);
            end
            % load information file
            info = LoadInfoFile(row);
            % carry out alignment
            switch currentalignoption
            case 'Turboreg translation'
                info.align.method = 'turboreg_translation';
                aligndata = AlignTurboRegTranslation(in_file,out_file);
                info.align.tform = aligndata.tform;
                info.align.referenceimage = aligndata.referenceimage;
                info.metadata.isstack = true;
            case 'Matlab'
                info.align.method = 'matlab';
                aligndata = AlignMatlab(in_file,out_file);
                info.align.tform = aligndata.tform;
                info.align.referenceimage = aligndata.referenceimage;
                info.metadata.isstack = true;
            case 'Turboreg rigidbody' 
                info.align.method = 'turboreg_rigidbody';
                aligndata = AlignTurboReg(in_file,out_file);
                info.align.tform = aligndata.tform;
                info.align.referenceimage = aligndata.referenceimage;
                info.metadata.isstack = true;
            case 'Image Stabilizer'               
                info.align.method = 'image_stabilizer';
                disp('not working yet');
                info.metadata.isstack = true;
            case '4D stack'
                if strcmp(info.type,'olympusXYT') % if olympus file has no period it's probably a galvo stack
                    info.align.method = 'turboreg_translation';
                    aligndata = AlignTurboRegTranslation(in_file,out_file);
                    info.align.tform = aligndata.tform;
                    info.align.referenceimage = aligndata.referenceimage;
                    info.metadata.isstack = false;                    
                elseif strcmp(info.type,'olympusXYZT') % if olympus file has no period it's probably a galvo stack
                    info.align.method = 'olympus4d';
                    if ~exist(out_file)                    
                        % this creates a small stack 
                        AlignOlympus4D(in_file,out_file);
                    end
                    % if olympus, then do a final alignment
                    output_file = fullfile(align_out_folder,'aligned.tif');
                    aligndata = AlignTurboRegTranslation(out_file, output_file);
                    info.align.tform = aligndata.tform;
                    info.align.referenceimage = aligndata.referenceimage;                
                    info.metadata.isstack = true;
                else
                    info.align.method = 'turboreg_translation';
                    aligndata = AlignTurboRegTranslation(in_file,out_file);                    
                    info.align.tform = aligndata.tform;
                    info.align.referenceimage = aligndata.referenceimage;
                    info.metadata.isstack = false;
                end
            otherwise
                disp('current align option is confused')
                keyboard
            end
            info.align.date = datestr(now,'yyyy-mm-dd-HH:MM');
            info.version = 0.4;
            SaveInfoFile(info,row)
            % update filedata
            filedata{row,3} = true;
            filedata{row,4} = true;
            filedata{row,5} = info.version;
            filedata{row,7} = info.metadata.isstack;
            set(FileTable,'Data',filedata);
            
        end   
        set(StatusText,'String','Current Status')    
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cell picking interface
CellPanel = uipanel('Title','Cell Panel','Units','centimeters');
set(CellPanel,'Position',[18 15 5 6.5],'BackgroundColor',[.8 .8 .8]);

UpdateInfoButton = uicontrol('Parent',CellPanel,'Style','PushButton');
set(UpdateInfoButton,'String','Update Info','Units','centimeters');
set(UpdateInfoButton,'Callback',@UpdateInfoFunction);
set(UpdateInfoButton,'Position',[.5 4.5 3 1]);
    function [] = UpdateInfoFunction(~,~)
        % update Status
        set(StatusText,'String','Updating Info');
        
        % check if selected data
        if isempty(selecteddata)
            set(StatusText,'String','no datasets selected');
            return
        end

        % identify imaging sets to process 
        numselected = size(selecteddata,1);
        for i=1:numselected
            set(StatusText,'String',[num2str(i) ' of ' num2str(numselected)]);
            row = selecteddata(i,1);
            currentfiledata = filedata{row,:};            
            align_in_folder = fullfile(input_folder, filedata{row,1}, filedata{row,2});
            align_out_folder = fullfile(output_folder, filedata{row,1}, filedata{row,2});


            % if info_file doesn't exist skip
            info_file = fullfile(align_out_folder,'info.mat');
            if ~exist(info_file)
                set(StatusText,'String','info file not found');
                disp(['img not found: ' info_file])
                % skip to next file
                continue
            end         
            % load info structure
            temp = load(info_file);
            info = temp.info;

            if strcmp(info.type,'olympus')
                % if img_file doesn't exist skip
                img_file = fullfile(align_out_folder,[filedata{row,2} '.tif']);
                if ~exist(img_file)
                    set(StatusText,'String','img file not found');
                    disp(['img not found: ' img_file])
                    % skip to next file
                    continue
                end
            elseif strcmp(info.type,'epi single-tif')
                temp = dir(fullfile(align_out_folder,'*.tif'));
                if isempty(temp)
                    set(StatusText,'String','img file not found');
                    disp(['img not found: ' img_file])
                    % skip to next file
                    continue
                end               
                % if img_file doesn't exist skip
                img_file = fullfile(align_out_folder,temp.name);
                output_file = img_file;
            else
                % if img_file doesn't exist skip
                img_file = fullfile(align_out_folder,['aligned.tif']);
                if ~exist(img_file)
                    set(StatusText,'String','img file not found');
                    disp(['img not found: ' img_file])
                    % skip to next file
                    continue
                end               
                output_file = img_file;
            end
            % populate information
            data = imreadtiffstack(img_file);
            info.img.max_projection = max(data,[],3);
            info.img.width = size(data,1);
            info.img.height = size(data,2);
            info.version = '0.5';

            save(info_file,'info')

            % update filedata
            filedata{row,5} = info.version;
            set(FileTable,'Data',filedata);

        end       

        % update Status
        set(StatusText,'String','Ready');

    end

ManualPickButton = uicontrol('Parent',CellPanel,'Style','PushButton');
set(ManualPickButton,'String','Select Cells','Units','centimeters');
set(ManualPickButton,'Callback',@ManualPickFunction);
set(ManualPickButton,'Position',[.5 3.5 3 1]);
    function [] = ManualPickFunction(~,~)
        % update Status
        set(StatusText,'String','Spawn Cell Selector');
        % check if selected data
        if isempty(selecteddata)
            set(StatusText,'String','no datasets selected');
            return
        end

        % identify imaging sets to process 
        numselected = size(selecteddata,1);
        if numselected>1
            disp('only analyze first one')
        end
        row = selecteddata(1,1);
        currentfiledata = filedata{row,:};

        tif_file = fullfile(output_folder, filedata{row,1}, filedata{row,2},'aligned.tif');
        if ~exist(tif_file)            
            temp = dir(fullfile(output_folder, filedata{row,1}, filedata{row,2},'*.tif'));
            if isempty(temp)
                disp(['img not found: ' img_file])
            end
            tif_file = fullfile(output_folder, filedata{row,1}, filedata{row,2},temp.name);
        end
        % spawn interface for picking cells
        currentfig = playmovie(tif_file);
        waitfor(currentfig)

        % load info
        info = LoadInfoFile(row);

        % update filedata if cells have been picked
        if isfield(info,'cells')
            if isfield(info.cells,'numcells')
                filedata{row,6} = info.cells.numcells;
                set(FileTable,'Data',filedata);
            end
        end

        % update Status
        set(StatusText,'String','Ready');
    end

PlotButton = uicontrol('Parent',CellPanel,'Style','PushButton');
set(PlotButton,'String','Plot Cells','Units','centimeters');
set(PlotButton,'Callback',@PlotFunction);
set(PlotButton,'Position',[.5 2.5 3 1]);
    function [] = PlotFunction(~,~)
        % update Status
        set(StatusText,'String','Plotting Cells');
        % check if selected data
        if isempty(selecteddata)
            set(StatusText,'String','no datasets selected');
            return
        end
        % identify imaging sets to process 
        numselected = size(selecteddata,1);
        for z = 1:numselected
            row = selecteddata(z,1);
            % load info
            info = LoadInfoFile(row);
            infopath = filedata{row,9};

            switch info.type
                case 'epi single-tif'
                    info = GrabEpiStimType(infopath);
                case ' '
                    info = GrabStimType(infopath);                
                otherwise
                    disp('img type not yet supported')
                    keyboard
                    return
            end

            if isfield(info,'cells')
                % make plots
                disp(['numcells:' num2str(info.cells.numcells)])
                for q = 1:info.cells.numcells
                    PlotFigure = figure;
                    prepfigure(PlotFigure,[15 8]);
                    set(PlotFigure,'Units','centimeters')
                    PlotAxes = axes;
                    xdata = [1:length(info.cells.celltrace{q})]*info.img.period;
                    ydata = info.cells.celltrace{q};
                    [transients,v,med] = FastFindTransients(ydata,xdata);
                    celltrace = (ydata-med)./med;
                    plot(xdata,celltrace)
                    box off
                    axis off
                    for r = 1:7
                        h = .05;
                        rectangle('Position',[info.stim.onsets(r),-.45 info.stim.duration,h],'FaceColor',[.2 .2 .2])
                        text(info.stim.onsets(r)+.5*info.stim.duration,-.6+h+h/2,info.stim.types{r},'HorizontalAlignment','center','FontSize',6)
                    end
                    set(gca,'YLim',[-.6 1.0])
                    temp = strrep(infopath,input_folder,'');
                    temp = temp(2:(end-9));
                    temp = strrep(temp,filesep,'-');
                    savefile = fullfile(input_folder,[temp '-' leadingnum2str(q,2) '.pdf']);
                    print(gcf,'-dpdf',savefile)
                    disp(savefile)
                    close(PlotFigure);
                end
            else
            set(StatusText,'String','dataset has no cells selected');
            end                
        end
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%
% debug interface
DebugPanel = uipanel('Title','Debug Panel','Units','centimeters');
set(DebugPanel,'Position',[18 10 5 4.5],'BackgroundColor',[.8 .8 .8]);

ImageJButton = uicontrol('Parent',DebugPanel,'Style','PushButton');
set(ImageJButton,'String','Open in ImageJ','Units','centimeters');
set(ImageJButton,'Callback',@ImageJFunction);
set(ImageJButton,'Position',[.5 .5 3 1]);
    function [] = ImageJFunction(~,~)
        % check if selected data
        if isempty(selecteddata)
            set(StatusText,'String','no datasets selected');
            return
        end

        % identify imaging sets to process 
        numselected = size(selecteddata,1);
        if numselected>1
            disp('only analyze first one')
        end
        row = selecteddata(1,1);
        currentfiledata = filedata{row,:};            
        tif_file = fullfile(output_folder, filedata{row,1}, filedata{row,2},'aligned.tif');
        StartMiji;
        MIJ.run('Open...', ['path=[' tif_file ']']);
    end

InfoButton = uicontrol('Parent',DebugPanel,'Style','PushButton');
set(InfoButton,'String','Check info.mat','Units','centimeters');
set(InfoButton,'Callback',@InfoFunction);
set(InfoButton,'Position',[.5 1.5 3 1]);
    function [] = InfoFunction(~,~)
        % check if selected data
        if isempty(selecteddata)
            set(StatusText,'String','no datasets selected');
            return
        end

        % identify imaging sets to process 
        numselected = size(selecteddata,1);
        if numselected>1
            disp('only analyze first one')
        end
        row = selecteddata(1,1);
        info_file = filedata{row,9};
        if ~exist(info_file,'file')
            disp('selected info file does not exist')
            return
        end
        
        temp = load(info_file);
        info = temp.info;
        keyboard
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper subfunctions

    % loads info.mat struct from selected row
    function output_info = LoadInfoFile(input_row)
        info_file = filedata{input_row,9}; % absolute path of info.mat
        % if info_file doesn't exist skip
        if ~exist(info_file)
            % skip to next file
            output_info = [];
            return
        end            
        % load info structure
        temp = load(info_file);
        output_info = temp.info;
    end
    % saves info.mat struct from selected row
    function SaveInfoFile(input_info,input_row)
        info_file = filedata{input_row,9}; % absolute path of info.mat
        info = input_info;
        save(info_file,'info');
    end
end

