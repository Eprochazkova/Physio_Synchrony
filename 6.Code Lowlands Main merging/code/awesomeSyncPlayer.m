function [hFig, WMP1, WMP2] = awesomeSyncPlayer(dyad)
% Quick script for syncronized playback of dyad data.

%% Generate GUI:


% Params:
opengl hardwarebasic;
bgCol       = [1 1 1];
colors      = lines(2);

% Make figure:
hFig = figure( 'Name','LOWLANDS SYNC PLAYER' ...
    ,'MenuBar', 'none' ...
    ,'Toolbar', 'figure' ...
    ,'NumberTitle', 'off'...
    ,'Units','normalized'...
    ,'Position',[0.1 0.15 0.8 0.7]...
    ,'Color', bgCol ...
    ,'Visible','on');
drawnow;
figKids = allchild(findall(hFig,'type','uitoolbar'));
tagToKeep = {'Exploration.Pan'...
    'Exploration.ZoomOut'...
    'Exploration.DataCursor'...
    'Exploration.ZoomIn'};
keepIndx = ismember(get(figKids,'Tag'),tagToKeep);
delete(figKids(~keepIndx));
set(figKids(keepIndx),'Separator','off')
hW = waitbar(0.5,'Wait','WindowStyle','Modal');
drawnow;

% Make Layout Managers:
mainVBOX    = uix.VBoxFlex('padding',10,'spacing',10,'parent',hFig...
    ,'BackgroundColor',bgCol); 
topRowHBOX = uix.HBox('parent',mainVBOX,'BackgroundColor',bgCol...
    ,'Spacing',10,'Padding',10);
middleRowHBOX = uix.HBox('parent',mainVBOX,'BackgroundColor',bgCol...
    ,'Spacing',10,'Padding',10);
bottomRowHBOX = uix.HBox('parent',mainVBOX,'BackgroundColor',bgCol...
    ,'Spacing',10,'Padding',10);
mainVBOX.Heights = [50 -1 -1.2];

% Make Buttons:
buttons.sync1 = uicontrol('Parent',topRowHBOX...
    ,'Style','pushbutton'...
    ,'String','Sync PPN1 to PPN2','tag','PPN1sync');
buttons.reload = uicontrol('Parent',topRowHBOX...
    ,'Style','pushbutton'...
    ,'String','Reload Vids','tag','reload');
buttons.sync2 = uicontrol('Parent',topRowHBOX...
    ,'Style','pushbutton'...
    ,'String','Sync PPN2 to PPN1','tag','PPN2sync');
% buttons.playBoth = uicontrol('Parent',topRowHBOX...
%     ,'Style','pushbutton'...
%     ,'String','Play Both','tag','play');
% buttons.pauseBoth = uicontrol('Parent',topRowHBOX...
%     ,'Style','pushbutton'...
%     ,'String','Pause Both','tag','pause');

% Make WMP containers:
makeWMPboxes = @(col)  ...
    uipanel('Parent',uix.HBox('Parent',middleRowHBOX...
    ,'Padding',10,'BackgroundColor',col),'BackgroundColor',col);
playerBox1 = makeWMPboxes(colors(1,:));
playerBox2 = makeWMPboxes(colors(2,:));

% Make activeX controls:
progId = 'WMPlayer.OCX.7';
WMP1 = actxcontrol(progId,'parent',hFig...
    ,'position',getpixelposition(playerBox1,true));
WMP2 = actxcontrol(progId,'parent',hFig...
    ,'position',getpixelposition(playerBox2,true));
resizerFcn = @(~,~) ([WMP1.move(getpixelposition(playerBox1,true))...
    WMP2.move(getpixelposition(playerBox2,true))]);
hFig.SizeChangedFcn = resizerFcn;
addlistener(playerBox2, 'SizeChanged',resizerFcn);
            
% Make the tabs:
tabPanel = uipanel('parent',bottomRowHBOX...
    ,'BackgroundColor',[240 240 240]/255);
tabPanelPadder = uix.HBox('parent',tabPanel...
    ,'BackgroundColor',[240 240 240]/255 ...
    ,'Spacing',10,'Padding',10);
tabGroup = uitabgroup('parent',tabPanelPadder);
sectionTab = uitab('parent',tabGroup,'Title','Scored Sections');
physioTab  = uitab('parent',tabGroup,'Title','Physio Data');


%% Plot sections:

plotSection = @(hAxis) plot(hAxis,[repmat(dyad.globalBounds(1),2,1)...
    repmat(dyad.globalBounds(2),2,1)] ...
    ,[hAxis.YLim' hAxis.YLim'],'r--','LineWidth',2);
horzLabelParams = {'Rotation',0 ...
    ,'FontSize',8 ...
    ,'VerticalAlignment','middle'...
    ,'HorizontalAlignment','right'};
signalAxesParams = ...
    {'box','on'...
    ,'XGrid','on','XMinorGrid','on'...
    ,'Color',[0.95 0.95 0.95]...
    ,'YGrid','on','YMinorGrid','on'...
    ,'TickLength',[0 0]};

% Make axes:
bounds = [160 6 45 1];
topCor = [0 0 0 30];
botCor = [0 45 0 0];
makeAxes = @(parent,coors) getfield(makeAxesContainer(parent,coors...
    ,{'BackgroundColor' bgCol},signalAxesParams),'ax');
hSectionAxes = makeAxes(sectionTab,bounds+topCor+botCor);
plotSectionBars(hSectionAxes,dyad,colors);
plotSection(hSectionAxes); xlabel(hSectionAxes,'Time [s]')
drawnow;


%% Plot Physio:

% Make axes:
axesVbox = uix.VBoxFlex('parent',physioTab,'BackgroundColor',bgCol);
hAxis(1) = makeAxes(axesVbox,bounds+topCor);
hAxis(2) = makeAxes(axesVbox,bounds);
hAxis(3) = makeAxes(axesVbox,bounds);
hAxis(4) = makeAxes(axesVbox,bounds+botCor);
axesVbox.Heights = -1*[1 1 1 1];

% Precalculate the times:
t.biopac1 = tGetFromDataStructField(dyad.Biopac_1.data);
t.biopac2 = dyad.Biopac_2.delay.seconds...
    +tGetFromDataStructField(dyad.Biopac_2.data);
t.tobii1 = dyad.Tobii_1.delay.seconds...
    +(dyad.Tobii_1.dataObj.diameter.t_ms/1000);
t.tobii2 = dyad.Tobii_2.delay.seconds...
    +(dyad.Tobii_2.dataObj.diameter.t_ms/1000);

% Plot Synced Markers:
plot(hAxis(1),t.biopac1,dyad.Biopac_1.data.channels{5}...
    ,'LineWidth',2,'Color',colors(1,:));
hold on;
plot(hAxis(1),t.biopac2,dyad.Biopac_2.data.channels{3}...
    ,'--','LineWidth',2,'Color',colors(2,:));
ylabel(hAxis(1),'BIOPAC-MARKERS',horzLabelParams{:});...
set(hAxis(1),'XTickLabel','');
plotSection(hAxis(1));
legend(hAxis(1),{'Data from Biopac 1' 'Data from Biopac 2' ...
    'Span of output file'});

% Plot synced EDA:
plot(hAxis(2),t.biopac1...
    ,zscore(dyad.Biopac_1.data.channels{2}),'LineWidth',2 ...
    ,'Color',colors(1,:)); hold on
plot(hAxis(2),t.biopac2...
    ,zscore(dyad.Biopac_2.data.channels{2}),'-','LineWidth',2 ...
    ,'Color',colors(2,:));
ylabel(hAxis(2),'BIOPAC-EDA (Z)',horzLabelParams{:});
set(hAxis(2),'XTickLabel','');
plotSection(hAxis(2));
legend(hAxis(2),{'Data from Biopac 1' 'Data from Biopac 2' ...
    'Span of output file'});

% Plot synced ECG:
plot(hAxis(3),t.biopac1...
    ,(dyad.Biopac_1.data.channels{1}),'LineWidth',2 ...
    ,'Color',colors(1,:)); hold on
plot(hAxis(3),t.biopac2...
    ,(dyad.Biopac_2.data.channels{1}),'-','LineWidth',2 ...
    ,'Color',colors(2,:));
ylabel(hAxis(3),'BIOPAC-ECG (Z)',horzLabelParams{:});
set(hAxis(3),'XTickLabel','');
plotSection(hAxis(3));
legend(hAxis(3),{'Data from Biopac 1' 'Data from Biopac 2' ...
    'Span of output file'});

% Plot diameters:
nanzscore = @(x) (x-nanmean(x))./nanstd(x);
plot(hAxis(4),t.tobii1...
    ,nanzscore(mean(...
    [dyad.Tobii_1.data.diameter.L dyad.Tobii_1.data.diameter.R],2))...
    ,'.','Color',colors(1,:)); hold on
plot(hAxis(4),t.tobii2...
    ,nanzscore(mean(...
    [dyad.Tobii_2.data.diameter.L dyad.Tobii_2.data.diameter.R],2))...
    ,'.','Color',colors(2,:));
ylabel(hAxis(4),'Tobii Pupil Dia. (Z)',horzLabelParams{:});
xlabel(hSectionAxes,'Time [s]')
plotSection(hAxis(4));
legend(hAxis(4),{'Data from Tobii 1' 'Data from Tobii 2' ...
    'Span of output file'});

%% Plot sync Lines:

% add sync lines:
plotSync = @(hAxesIn) [plot(hAxesIn,[100 100]...
    ,hAxesIn.YLim,'Color',colors(1,:)...
    ,'LineWidth',2) plot(hAxesIn,[1000 1000]...
    ,hAxesIn.YLim,'Color',colors(2,:)...
    ,'LineWidth',2)];
hSyncLines = [plotSync(hSectionAxes)...
    ;plotSync(hAxis(1))...
    ;plotSync(hAxis(2))...
    ;plotSync(hAxis(3))...
    ;plotSync(hAxis(4))];


%% Finalize and Initialize:

linkaxes([hAxis hSectionAxes],'x');


% Precalc delays:
WMPdelays = [(dyad.Tobii_1.delay.seconds...
    +(dyad.Tobii_1.dataObj.vidStream.fullVid.timeCorrection(1,1)/1e6))...
    ...
    (dyad.Tobii_2.delay.seconds...
    +(dyad.Tobii_2.dataObj.vidStream.fullVid.timeCorrection(1,1)/1e6))];

% Run video Loadedr Load videos:
reloadVids(dyad,WMP1,WMP2)

% Make timer to update sync lines:
T = timer('ExecutionMode','FixedRate'...
    ,'TimerFcn',{@timerCB,WMP1,WMP2,hSyncLines,WMPdelays} ...
    ,'Period',0.1);
start(T);
 

%% Set Menu:

% Add menu:
axsMenu = uicontextmenu(hFig);
uimenu(axsMenu,'Label','Go to this point in the videos'...
    ,'Callback',{@syncCB,WMP1,WMP2,WMPdelays,T}...
    ,'Tag','jump');
arrayfun(@(ff) set(get(ff,'Children'),'HitTest','off')...
    ,[hSectionAxes hAxis]);
set([hSectionAxes hAxis], 'UIContextMenu',axsMenu);

% Also make menu work when panning and zooming:
panObj = pan(hFig);
zoomObj = zoom(hFig);
set(panObj,'ButtonDownFilter',@(~,~) false);
set(zoomObj,'ButtonDownFilter',@(~,~) false);
pan('off')
zoom('off')
set(panObj, 'UIContextMenu',axsMenu)
set(zoomObj, 'UIContextMenu',axsMenu)


%% Register Button Callbacks:

hFig.CloseRequestFcn = @(~,~) closeWin(T,hSyncLines);
set([buttons.sync1 buttons.sync2]...
    ,'Callback',{@syncCB,WMP1,WMP2,WMPdelays,T},'BusyAction','cancel'...
,'Interruptible','off');
set(buttons.reload,'callback',{@(~,~) reloadVids(dyad,WMP1,WMP2)}...
    ,'BusyAction','cancel'...
,'Interruptible','off');


%% Finalzize:

hFig.Visible = 'on';

drawnow;
delete(hW);


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Close Window CB:


function closeWin(T,syncLines)
stop(T);
delete(gcbf);

if ~any(isempty(syncLines))&&all(isvalid(syncLines(:)))
    set(syncLines(:),'XData',[NaN NaN]);
end

end



%% Time CB:

function timerCB(src,~,WMP1,WMP2,syncLines,delays)

try
    p1 = WMP1.Control.currentPosition+delays(1);
    p2 = WMP2.Control.currentPosition+delays(2);
    set(syncLines(:,1),'XData',[p1 p1]);
    set(syncLines(:,2),'XData',[p2 p2]);
catch
    stop(src)
end

end


%% Reload Vids CB:

function reloadVids(dyad,WMP1,WMP2)

WMP1.URL = [dyad.dyadDir dyad.Tobii_1.dataObj.vidStream.fullVid...
    .relFilename];
WMP2.URL = [dyad.dyadDir dyad.Tobii_2.dataObj.vidStream.fullVid...
    .relFilename];

end



%% Sync Vids CB:

function syncCB(src,~,WMP1,WMP2,WMPdelays,T)
% Syncs the videos.

% Determine whether or not to play the videos after syncing:
playAfter = ~strcmp({get(WMP1,'status') get(WMP2,'status')},'Paused');
if ismember(src.Tag,{'PPN1sync', 'PPN2sync'})&&any(playAfter)
    playAfter = [true true];
end
        
% Stop the timer:
if ~isempty(T); stop(T); end;

% Force pause the videos:
WMP1.Control.pause;
WMP2.Control.pause;

% Check what to do:
switch src.Tag
    
    case 'PPN1sync'
        idealPosition = WMP2.Control.currentPosition+WMPdelays(2);

    case 'PPN2sync'
        idealPosition = WMP1.Control.currentPosition+WMPdelays(1);
        
    case 'jump'
        pos = get(gca,'CurrentPoint');
        idealPosition = pos(1);
end

% Set playes to ideal position:
WMP1.Control.currentPosition = idealPosition-WMPdelays(1);
WMP2.Control.currentPosition = idealPosition-WMPdelays(2);

% Replay, wait and, check delay, pause, correct delay, replay:
WMP1.Control.play;
WMP2.Control.play;
pause(0.2)
lead = (WMP1.Control.currentPosition+WMPdelays(1))...
    -(WMP2.Control.currentPosition+WMPdelays(2));
WMP1.Control.pause;
WMP2.Control.pause;
WMP1.Control.currentPosition = idealPosition-WMPdelays(1)-lead;
WMP2.Control.currentPosition = idealPosition-WMPdelays(2);
WMP1.Control.play;
WMP2.Control.play;
if ~playAfter(1)
    WMP1.Control.pause;
end
if ~playAfter(2)
    WMP2.Control.pause;
end

if ~isempty(T); start(T); end;

end
