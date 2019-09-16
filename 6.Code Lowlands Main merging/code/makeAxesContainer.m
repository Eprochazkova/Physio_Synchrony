function h = makeAxesContainer(axParent,padding,contProps,axProps)
%  makeAxesContainerFunction for generating an axes inside a uicontainer,
%  with auto resize.
%
%    h = makeAxesContainer(axParent[,axesInsideParentOffset)]
%
%--------------------------------------------------------------------------
%   Part of the PhysioData Toolbox.
%    Elio Sjak-Shie, Faculty of Social Sciences,
%     Leiden University, 2016.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Changelog:
%
%   Oct-2016 -- Elio:
%        > Wrote first version.
%
%--------------------------------------------------------------------------

% Generate uicontainer pixel-position offsets from padding input:
axesInsideParentOffset = [padding(1) padding(2) ...
    (-sum(padding([1 3]))) (-sum(padding([2 4])))];
signalAxesParams =  {'box','on'...
            ,'XGrid','on','XMinorGrid','on'...
            ,'Color',[0.95 0.95 0.95]...
            ,'YGrid','on','YMinorGrid','on'};

% Build container and axes child:
h.axContainer = uipanel('Parent',axParent,'BorderType','none'...
    ,contProps{:});
h.ax          = axes('Parent',h.axContainer...
    ,signalAxesParams{:},axProps{:}); hold(h.ax,'on');
setappdata(h.ax ,'axesInsideParentOffset',axesInsideParentOffset);

% Set the resize function:
h.axContainer.ResizeFcn = @processResize;

% Run the resize:
processResize(h.axContainer);

    function processResize(~,~)
        % Resize CB function.
        
        % Get the parent position, apply offset, and update the child:
        if isvalid(h.ax)
            newpos = getpixelposition(h.axContainer,true)...
                +getappdata(h.ax ,'axesInsideParentOffset');
            newpos(newpos<1) = 1;
            setpixelposition(h.ax,newpos,true);
            
            % MATLAB BUG CAUSES THE LINES TO STRETCH OUT WHEN
            % RESIZING THE AXES, THIS IS A WORKAROUND TO FORCE MATLAB TO
            % RERENDER THE AXES:
%                         drawnow;
%             h.ax.XLim = h.ax.XLim+(10e-1*(((randi([0 1],1))*2)-1));
        end
    end

end

