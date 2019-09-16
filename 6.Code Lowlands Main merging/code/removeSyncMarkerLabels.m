function sOut = removeSyncMarkerLabels(sIn)
% Removes the SyncPortOutHigh and SyncPortOutLow labels from Tobii Analyzer
% outputs.
%
%   sOut = removeSyncMarkerLabels(sIn) where sIn is a struct with the
%   eyeTracking field.

% Labels to remove:
labelsToRemove = {'SyncPortOutHigh' 'SyncPortOutLow'};

% Process struct:
sOut = sIn;
for ETindx = 1:length(sIn.eyeTracking)
    removeThese = ismember(sOut.eyeTracking(ETindx).labels.name...
        ,labelsToRemove);
    sOut.eyeTracking(ETindx).labels.name(removeThese) = [];
    sOut.eyeTracking(ETindx).labels.t_ms(removeThese) = [];
end

end