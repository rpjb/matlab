% playmovie is an interface for manually selecting interesting cells from a tif stack  
%
% playmovie spawns a basic video viewer, and some filtering options. the user then selects cells.
%
% type: function
%
% inputs: 
%   file - a string containing the absolute path to a tif stack.
%     it is assumed that an info.mat for saving cells is in the same folder 
%   
% outputs: none
%
% dependencies:
%   Miji
%
% Robert Barretto, robertb@gmail.com
% 02/16/2015 5:02pm


function DisplayFigure = playmovie(varargin)

% load input file, or if none provided, default to a test file
if nargin == 0
    if ismac
        file = '/Volumes/USB 2/aligned buds/071414 t1r2/bud 1_0001/aligned.tif';
    else
        file = 'J:\aligned buds\072514 aqp11\bud 1\aligned.tif';
    end
else
    file = varargin{1};
end

%% load the video
if isempty(file)
    disp('No file found.')
    return
end
if ~exist(file)
    disp('File not found.')
    return
end

%% load info file if it exists
[folder,~,~] = fileparts(file)
info_file = fullfile(folder,'info.mat');
if exist(info_file)
    temp = load(info_file);
    info = temp.info;
end

% setup variables for data
originaldata = uint16(imreadtiffstack(file));
data = originaldata;
filtereddata = [];
dffdata = [];
dfffiltereddata = [];
datadim = size(data);
dataintensityrange = [min(data(:)) max(data(:))];


%% initialize variables
% frames to play
minframe = 1;
maxframe = datadim(3);
startframe = minframe;
endframe = maxframe;
currentframe = 1;
frameperiod = .005; % 5ms frame rate for playback

    
% break warning
stopflag = 0;

%% figure
DisplayFigure = figure;
set(DisplayFigure,'units','centimeters','position',[5 5 24.5 17])
set(DisplayFigure,'name',file,'numbertitle','off')

%% movie display
MovieAxis = axes;
set(MovieAxis,'units','centimeters','position', [8 .5 16 16])

%% frame display axes
DataImg = imshow(zeros(datadim(1),datadim(2)),[],'Parent',MovieAxis);
set(MovieAxis,'CLim',dataintensityrange)

%% contour display axes
hold on
contourmask = zeros(datadim(1),datadim(2),3);
ContourImg = imshow(contourmask,'Parent',MovieAxis);
set(ContourImg,'AlphaData',  max(contourmask,[],3) > 0)
hold off

%% cell contour structure
cellcontours = [];
% load cellcontours from info if exist
if exist('info','var')
    if isfield(info,'img')
        set(DataImg,'CData',info.img.max_projection);
    else
        set(DataImg,'CData',data(:,:,currentframe));
    end
    if isfield(info,'cells')
        cellcontours = info.cells.cellcontours;
        UpdateContourImg;
    end
end



%%%%%%%%%%%%%%%%%
%% video controls
%%%%%%%%%%%%%%%%%
PlayText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(PlayText,'BackgroundColor',[.8 .8 .8])
set(PlayText,'String','Movie controls','Units','centimeters');
set(PlayText,'Position',[.5 2.5 6 .5]);

PlayButton = uicontrol(DisplayFigure,'Style','PushButton');
set(PlayButton,'String','play','Units','centimeters');
set(PlayButton,'Callback',@PlayFcn);
set(PlayButton,'Position',[.5 .5 2 .5]);
    function [] = PlayFcn(~,~)
        for currentframe=startframe:1:endframe
            set(CurrentFrameText,'String',currentframe);
            set(DataImg,'CData',data(:,:,currentframe));
            pause(frameperiod)
            if stopflag == 1
                stopflag = 0;
                return
            end
        end
    end
StopButton = uicontrol(DisplayFigure,'Style','PushButton');
set(StopButton,'String','stop','Units','centimeters');
set(StopButton,'Callback',@StopFcn);
set(StopButton,'Position',[.5 1 2 .5]);
    function [] = StopFcn(~,~)
        stopflag = 1;
    end

BackButton = uicontrol(DisplayFigure,'Style','PushButton');
set(BackButton,'String','-1 frame','Units','centimeters');
set(BackButton,'Callback',@BackFcn);
set(BackButton,'Position',[.5 1.5 2 .5]);
    function [] = BackFcn(~,~)
        currentframe = max(minframe,currentframe-1);
        set(CurrentFrameText,'String',currentframe);
        set(DataImg,'CData',data(:,:,currentframe));
    end

ForwardButton = uicontrol(DisplayFigure,'Style','PushButton');
set(ForwardButton,'String','+1 frame','Units','centimeters');
set(ForwardButton,'Callback',@ForwardFcn);
set(ForwardButton,'Position',[.5 2 2 .5]);
    function [] = ForwardFcn(~,~)
        currentframe = min(maxframe,currentframe+1);
        set(CurrentFrameText,'String',currentframe);
        set(DataImg,'CData',data(:,:,currentframe));
    end

FrameRate = uicontrol(DisplayFigure,'Style','Edit');
set(FrameRate,'String',num2str(1/frameperiod),'Units','centimeters')
set(FrameRate,'Callback',@FrameRateCallback)
set(FrameRate,'Position',[5.5 2 1 .5])
    function [] = FrameRateCallback(~,~)
        frameperiod = 1/str2num(get(FrameRate,'String'));
    end
FrameRateTxt = uicontrol(DisplayFigure,'Style','Text');
set(FrameRateTxt,'String','framerate','Units','centimeters')
set(FrameRateTxt,'Position',[3 2 2 .5])

StartingFrame = uicontrol(DisplayFigure,'Style','Edit');
set(StartingFrame,'String','1','Units','centimeters')
set(StartingFrame,'Callback',@StartingFrameCallback)
set(StartingFrame,'Position',[5.5 1 1 .5])
    function [] = StartingFrameCallback(~,~)
        startframe = max(1,str2num(get(StartingFrame,'String')));
    end
StartingFrameTxt = uicontrol(DisplayFigure,'Style','Text');
set(StartingFrameTxt,'String','start','Units','centimeters')
set(StartingFrameTxt,'Position',[3 1 2 .5])

EndingFrame = uicontrol(DisplayFigure,'Style','Edit');
set(EndingFrame,'String',num2str(datadim(3)),'Units','centimeters')
set(EndingFrame,'Callback',@EndingFrameCallback)
set(EndingFrame,'Position',[5.5 1.5 1 .5])
    function [] = EndingFrameCallback(~,~)
        endframe = min(datadim(3),str2num(get(EndingFrame,'String')));
    end
EndingFrameTxt = uicontrol(DisplayFigure,'Style','Text');
set(EndingFrameTxt,'String','end','Units','centimeters')
set(EndingFrameTxt,'Position',[3 1.5 2 .5])

CurrentFrameText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(CurrentFrameText,'String','1','Units','centimeters');
set(CurrentFrameText,'Position',[5.5 .5 1 0.5]);

CurrentFrameLabel = uicontrol(DisplayFigure,'Style','text');
set(CurrentFrameLabel,'String','frame','Units','centimeters');
set(CurrentFrameLabel,'Position',[3 .5 2 .5]);

%% button for keyboard
KeyboardButton = uicontrol(DisplayFigure,'Style','PushButton');
set(KeyboardButton,'String','keyboard','Units','centimeters');
set(KeyboardButton,'Callback',@KeyboardFcn);
set(KeyboardButton,'Position',[3 10 2 .5]);
    % function for kuwahara cells
    function [] = KeyboardFcn(~,~)
        keyboard
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% processed video to display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ProcessText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(ProcessText,'BackgroundColor',[.8 .8 .8])
set(ProcessText,'String','Process controls','Units','centimeters');
set(ProcessText,'Position',[.5 5 6 .5]);


% state variables
usefilterindex = 0;
usedffindex = 0;
usedfffilterindex = 0;

% checkboxes for toggling
UseFilterButton = uicontrol(DisplayFigure,'Style','checkbox','Value',0);
set(UseFilterButton,'String','show filter','Units','centimeters');
set(UseFilterButton,'Callback',@UseFilter)
set(UseFilterButton,'Position',[3 3.5 2 .5])
set(UseFilterButton,'Enable','off')
    function [] = UseFilter(~,~)
        usefilterindex = get(UseFilterButton,'Value');
        if usefilterindex
            usefilterindex = 1;
        elseif ~usefilterindex
            usefilterindex = 0;
        end
        updatevideo;
    end
UseDFFButton = uicontrol(DisplayFigure,'Style','checkbox','Value',0);
set(UseDFFButton,'String','show dff','Units','centimeters');
set(UseDFFButton,'Callback',@UseDFF)
set(UseDFFButton,'Position',[3 4 2 .5])
set(UseDFFButton,'Enable','off')
    function [] = UseDFF(~,~)
        usedffindex = get(UseDFFButton,'Value');
        if usedffindex
            usedffindex = 1;
        elseif ~usedffindex
            usedffindex = 0;
        end
        updatevideo;
    end
UseDFFFilterButton = uicontrol(DisplayFigure,'Style','checkbox','Value',0);
set(UseDFFFilterButton,'String','show both','Units','centimeters');
set(UseDFFFilterButton,'Callback',@UseDFFFilter)
set(UseDFFFilterButton,'Position',[3 4.5 2 .5])
set(UseDFFFilterButton,'Enable','off')
    function [] = UseDFFFilter(~,~)
        usedfffilterindex = get(UseDFFFilterButton,'Value');
        if usedfffilterindex
            usedffindex = 0; usefilterindex = 0; usedfffilterindex = 1;
            set(UseFilterButton,'Value',0);
            set(UseDFFButton,'Value',0);            
        elseif ~usedfffilterindex
            usedfffilterindex = 0;
        end
        updatevideo;
    end
    % subfunction that checks the dff / filter indices and updates the data
    % range
    function [] = updatevideo()
        if usedfffilterindex
            data = dfffiltereddata;
            % incorporate a 250% max value, most neurons won't be above
            % this.  there is an edge issue with alignment that gives max
            % values > 10x
            maxval = min(2.5,nanmax(data(:)));
            dataintensityrange = [min(data(:)) max(data(:))];

        elseif usedffindex
            data = dffdata;
            maxval = min(2.5,nanmax(data(:)));
            dataintensityrange = [min(data(:)) max(data(:))];

        elseif usefilterindex
            data = filtereddata;
            maxval = nanmax(data(:));
            dataintensityrange = [min(data(:)) max(data(:))];

        elseif ~usedfffilterindex && ~usedffindex && ~usefilterindex
            data = originaldata;
            maxval = nanmax(data(:));
            dataintensityrange = [min(data(:)) max(data(:))];

        end
    end  
% buttons to request processing
FilterButton = uicontrol(DisplayFigure,'Style','PushButton');
set(FilterButton,'String','calc filter','Units','centimeters');
set(FilterButton,'Callback',@FilterFcn);
set(FilterButton,'Position',[.5 3.5 2 .5]);
    function [] = FilterFcn(~,~)
        [filtereddata] = KalmanPadStackFilter(originaldata);
        set(UseFilterButton,'Enable','on')
        set(FilterButton,'Enable','off')
    end
DFFButton = uicontrol(DisplayFigure,'Style','PushButton');
set(DFFButton,'String','calc dff','Units','centimeters');
set(DFFButton,'Callback',@DFFFcn);
set(DFFButton,'Position',[.5 4 2 .5]);
    function [] = DFFFcn(~,~)
        % the first ten frames look bad, so repeat the first ten frames
        d = size(originaldata);
        mediandata = double( repmat(median(data,3),[1 1 d(3)]) );
        dffdata = (double(originaldata) - mediandata) ./ (mediandata);
        set(UseDFFButton,'Enable','on')
        set(DFFButton,'Enable','off')
        set(DFFFilterButton,'Enable','on');

    end
DFFFilterButton = uicontrol(DisplayFigure,'Style','PushButton');
set(DFFFilterButton,'String','calc dfffilt','Units','centimeters');
set(DFFFilterButton,'Callback',@DFFFilterFcn);
set(DFFFilterButton,'Position',[.5 4.5 2 .5]);
set(DFFFilterButton,'Enable','off');
    function [] = DFFFilterFcn(~,~)
        % the first ten frames look bad, so repeat the first ten frames
        d = size(dffdata);
        r = zeros(d(1),d(2),d(3)+10);
        r(:,:,1:10) = double(dffdata(:,:,1:10));
        r(:,:,11:end) = double(dffdata);
        % run kalman stack and truncate first ten frames
        dfffiltereddata = KalmanStackFilter(r,.8,.05);
        dfffiltereddata = dffdata(:,:,11:end);
        set(UseDFFFilterButton,'Enable','on')
        set(DFFFilterButton,'Enable','off')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% image display parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImageText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(ImageText,'BackgroundColor',[.8 .8 .8])
set(ImageText,'String','Process controls','Units','centimeters');
set(ImageText,'Position',[.5 5 6 .5]);
%% sliders for image contrast
% status update
ContrastText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(ContrastText,'BackgroundColor',[.8 .8 .8])
set(ContrastText,'String','Image contrast','Units','centimeters');
set(ContrastText,'Position',[.5 7 2 .5]);
LowImgButton = uicontrol(DisplayFigure,'Style','slider');
set(LowImgButton,'Units','centimeters','Position',[.5 6 5 .5])
set(LowImgButton,'Min',0,'Max',100,'Value',10,'Callback',@UpdateImgFcn)
HighImgButton = uicontrol(DisplayFigure,'Style','slider');
set(HighImgButton,'Units','centimeters','Position',[.5 6.5 5 .5])
set(HighImgButton,'Min',0,'Max',100,'Value',90,'Callback',@UpdateImgFcn)
    function [] = UpdateImgFcn(~,~)
        % get and validate bounds
        n = round(get(LowImgButton,'Value'));
        m = round(get(HighImgButton,'Value'));       
        n = min(max(0,n),m); 
        m = max(min(100,m),n);
        if n>=m            
            m = n+1;
        end
        set(LowImgButton,'Value',n);
        set(HighImgButton,'Value',m);
        % adjust image lookup table on [0 maxval] scale
        % but ensure that Inf values are not occuring
        maxval = max(double(dataintensityrange));
        if isnan(maxval) || isinf(maxval)
            maxval = 1;
        end
        set(MovieAxis,'CLim',(maxval/100)*[n,m]   );
    end

%%%%%%%%%%%%%%%%%%%%%%%%
%% manual cell selection
%%%%%%%%%%%%%%%%%%%%%%%%
PickerText = uicontrol(DisplayFigure,'Style','text','HorizontalAlignment','left');
set(PickerText,'BackgroundColor',[.8 .8 .8])
set(PickerText,'String','Cell picking','Units','centimeters');
set(PickerText,'Position',[.5 9 6 .5]);


%% setup controls to pick cells

AddButton = uicontrol(DisplayFigure,'Style','PushButton');   
set(AddButton,'String','add cells','Units','centimeters');
set(AddButton,'Callback',@AddButtonCallback);
set(AddButton,'Position',[.5 8.5 2 .5]);
    function [] = AddButtonCallback(~,~)
            % highlighter tool to identify blob to add
            doneflag = 0;
            BW = {};
            while doneflag == 0
                roihandles = imfreehand(gca);
                cellmask = createMask(roihandles,ContourImg);
                if sum(cellmask(:)) == 0
                    doneflag = 1;
                else
                    BW{end+1} = cellmask;  
                end
            end
            % cleanup excess imfreehand objects
            delete(findobj('Tag','imfreehand'));
            if isempty(cellcontours)
                numcells = 0;
            else
                numcells = size(cellcontours,3);
            end 
            % add cellcontours

            % custom color map based on numbers of cells
            %for q = 1:length(BW)
            %    cellcontours(:,:,numcells+q) = (numcells+q)*(BW{q});
            %end            
            %customcmap = [[0 0 0];jet(size(cellcontours,3))];

            for q = 1:length(BW)
                cellcontours(:,:,numcells+q) = currentframe*(BW{q});
            end            
            % update display
            UpdateContourImg;

   
    end

RemoveButton = uicontrol(DisplayFigure,'Style','PushButton');   
set(RemoveButton,'String','remove cells','Units','centimeters');
set(RemoveButton,'Callback',@RemoveButtonCallback);
set(RemoveButton,'Position',[.5 8 2 .5]);
    function [] = RemoveButtonCallback(~,~)
            % highlighter tool to identify blob to remove
            doneflag = 0;
            BW = {};
            while doneflag == 0
                roihandles = imfreehand(gca);
                cellmask = createMask(roihandles,ContourImg);
                if sum(cellmask(:)) == 0
                    doneflag = 1;
                else
                    BW{end+1} = cellmask;
                end
            end
            % cleanup excess imfreehand objects
            delete(findobj('Tag','imfreehand'));

            % remove overlapping cellcontours
            numcells = size(cellcontours,3);
            cellstoremove = zeros(1,numcells);
            for q = 1:length(BW) % adds new cells to existing cellcontour matrix
                for j = 1:numcells
                    cellstoremove(j) = (sum(sum(BW{q}&cellcontours(:,:,j)))>0);
                end
            end
            cellcontours(:,:,logical(cellstoremove)) = [];

            % update display
            UpdateContourImg;
    end

SaveButton = uicontrol(DisplayFigure,'Style','PushButton');   
set(SaveButton,'String','save cells','Units','centimeters');
set(SaveButton,'Callback',@SaveButtonCallback);
set(SaveButton,'Position',[3 8 2 .5]);
    function [] = SaveButtonCallback(~,~)
        info.cells.datesaved = datestr(now,'yyyymmdd HH:MM');
        info.cells.numcells = size(cellcontours,3);
        info.cells.cellcontours = cellcontours;
        info.cells.celltrace = [];
        for i=1:info.cells.numcells
            maskeddata = double((originaldata.*repmat(uint16(cellcontours(:,:,i)>0),[1 1 maxframe])));
            info.cells.celltrace{i} = squeeze( sum(sum(maskeddata,1),2)/sum(sum(cellcontours(:,:,i)>0)) );
        end
        save(info_file,'info');
    end
    % utility function to update image
    function [] = UpdateContourImg
        % identify the selected regions
        if isempty(cellcontours)
            numcells = 0;
        else
            numcells = size(cellcontours,3);
        end                

        % custom color map based on frame number of selection
        customcmap = [[0 0 0];jet(maxframe)];

        % create a single image
        if numcells > 0 
            contourmask = ind2rgb(1+max(cellcontours,[],3),customcmap);
        else
            contourmask = ind2rgb(1+zeros(datadim(1),datadim(2)), customcmap);
        end
        % update display
        set(DataImg,'CData',data(:,:,currentframe));
        set(ContourImg,'CData',contourmask); 
        set(ContourImg,'AlphaData',  .2*(max(contourmask,[],3) > 0));
    end
end