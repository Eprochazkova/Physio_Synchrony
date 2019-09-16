function plotSectionBars(hAxes,dyad,colors)

%% Parse input:

assert(isequal([dyad.Tobii_1.data.eventSections.name]...
    ,[dyad.Tobii_2.data.eventSections.name])...
    ,'Files must have the same sections!');
sectionNames  = {dyad.Tobii_1.data.eventSections.name};

%% Plot:

% Proprocess:
nEvents = length(sectionNames);
hAxes.YLim   = [0.40 nEvents+0.6];
barDist      = [0.05 0.3];
levels       = 1:nEvents;

% Plot:
plotPP(dyad.Tobii_1,'down',colors(1,:))
plotPP(dyad.Tobii_2,'up',colors(2,:))
legend(hAxes,{'Data from Tobii 1' 'Data from Tobii 2'});

% Plot rectangles:
borderRectLim        = 0.40;
yPatchBottomBorder   = levels-borderRectLim;
yPatchTopBorder      = levels+borderRectLim;
startEndTimesBorder  = [-500 10000];

% Patch: Bottom-Left , Bottom-Right , Top-Right , Top-Left
yPatchBorder = [yPatchBottomBorder;yPatchBottomBorder...
    ;yPatchTopBorder;yPatchTopBorder];
xPatchBorder = repmat(([startEndTimesBorder'...
    ;flipud(startEndTimesBorder')]...
    ),1,nEvents);
hPatch = patch(xPatchBorder,yPatchBorder...
            ,[0.95 0.95 0.95],'parent',hAxes);
        hPatch.FaceAlpha = 1;%0.35;
uistack(hPatch,'bottom');

% Post format:
hAxes.ClippingStyle ='rectangle';
set(hAxes,'YTick',[hAxes.YLim(1) 1:nEvents hAxes.YLim(2)]...
    ,'YTickLabel',[' ' strrep(sectionNames,'_','\_') ' ']...
    ,'Box','on','XGrid','on','YGrid','on','Color',[1 1 1],'layer','top');
setAxesZoomMotion(zoom(ancestor(hAxes,'figure')),hAxes,'horizontal');
setAxesPanMotion(pan(ancestor(hAxes,'figure')),hAxes,'horizontal');
    function plotPP(sectionData1,row,col)
        
        % Get params:
        yPatchLevelC = arrayfun(@(c) ...
            c*ones(size(...
            sectionData1.data.eventSections(c).hit,1),1)...
            ,levels,'UniformOutput',false);
        yPatchLevel = vertcat(yPatchLevelC{:});
        yPatchBottom = yPatchLevel-barDist(2);
        yPatchTop    = yPatchLevel-barDist(1);
        
        if strcmp(row,'up')
            yPatchBottom = yPatchBottom + 2*mean(barDist);
            yPatchTop    = yPatchTop    + 2*mean(barDist);
        end
        startEndTimes = vertcat(sectionData1.data.eventSections...
            .hit)./1000;
        
        % Patch: Bottom-Left , Bottom-Right , Top-Right , Top-Left
        yPatch = [yPatchBottom';yPatchBottom';yPatchTop';yPatchTop'];
        xPatch = [startEndTimes(:,1)'...
            ;startEndTimes(:,2)'...
            ;startEndTimes(:,2)'...
            ;startEndTimes(:,1)']+sectionData1.delay.seconds;
        
        % Plot Patches:
        hPatch = patch(xPatch,yPatch...
            ,col,'parent',hAxes);
        set(hPatch,'EdgeColor',[20 20 20]/255) %
        
    end

end

