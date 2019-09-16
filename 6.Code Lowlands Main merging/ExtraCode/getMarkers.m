function [Markers] = getMarkers(markerSignalIN)
%GETMARKERS Transforms a marker signal to marker values and indeces
%
%   [Markers] = getMarkers(markerSignalIN) gets the marker values and the
%   marker on and of indeces from the marker signal markerSignalIN, and
%   returns them in the Markers matrix, with the columns: [markerValue
%   markerOnIndx markerOffIndx].
%
%   getMarkers removes leading non-zeros and transforms markerSignalIN into
%   a pure stepping signal by removing any up- or downslopes that are not
%   directly adjacent to platuaes. Sometimes, when a high marker is sent,
%   the DAQ unit records an intermediate value before the actual value is
%   reached; flattening up and downslopes prevents misregistering these
%   intermerdiate samples as marker values. Additionally, spikes--i.e.
%   zero-hold pulses--are removed.
%
%   If the last marker has an on event, but no off event--i.e., the
%   recording stops while the marker value is held--an off event is
%   created for the last marker, and placed at the end of the recording.
%
%--------------------------------------------------------------------------
%   Part of the PhysioData Toolbox.
%    Elio Sjak-Shie, Faculty of Social Sciences,
%     Leiden University, 2016.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Changelog:
%
%   April-2015 -- Elio:
%        > Wrote first version.
%
%--------------------------------------------------------------------------

% Check if signal is a digital marker channel:
if nnz(rem(markerSignalIN,1))>0
    error('The specified channel is not a digital marker channel.')
end

% force columnwise vector:
if size(markerSignalIN,2)>1
    markerSignalIN = markerSignalIN';
end
    
% Remove leading non-zeros:
if markerSignalIN(1)~=0;
    firstJump                   = find(diff(markerSignalIN)~=0,1);
    markerSignalIN(1:firstJump) = zeros(firstJump,1);
end

% Remove any up/down slopes that are not immediately followed by a plateau:
markerData       = [0; diff(markerSignalIN)];
markerSignalIN(conv(abs(sign(markerData)),[1 1],'same')==2) = 0;
markerData       = [0; diff(markerSignalIN)];

% Get number of jumps in the markers channel, and the accompanying value:
markJumps        = find(markerData~=0);
markVals         = markerSignalIN(markJumps)';

if ~isempty(markJumps)
    
    % Support missing off events:
    markJumps(end+1) = length(markerSignalIN);
    
    % Reshape jumps so that all intervals are considered epochs:
    startEndIndx = kron(markJumps,[1 1]');
    startEndIndx = reshape(startEndIndx(2:end-1)...
        ,[2 length(markJumps)-1])';
    
    % Consolidate the marker values and the marker indexes, remove epochs
    % with value zero, and subtract 1 from the epoch ends:
    Markers                    = [markVals' startEndIndx];
    Markers(Markers(:,1)==0,:) = [];
    Markers(:,3)               = Markers(:,3)-1;

else
    Markers= [];
end

% Activate to plot:
if false
    figure() %#ok<UNRCH>
    plot(markerSignalIN)
    hold on
    plot(Markers(:,2),Markers(:,1),'g.','MarkerSize',15)
    plot(Markers(:,3),Markers(:,1),'r.','MarkerSize',15)
end

end


