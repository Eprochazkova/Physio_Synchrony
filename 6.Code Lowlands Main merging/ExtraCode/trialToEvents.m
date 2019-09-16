function labels = trialToEvents(t_ms,trialId)

% Use the getMarkers function the analyze the trialId vector, prevent the
% function from removing the leading zero by padding it with a zero, of
% which the index is later subtracted:
Markers = getMarkers([0;trialId]);

% Generate Event Names
startEventNames = strcat({'Start_Trial_'}...
    ,strtrim(cellstr(num2str(Markers(:,1))))...
    );
endEventNames = strcat({'End_Trial_'}...
    ,strtrim(cellstr(num2str(Markers(:,1))))...
    );
eventNames = [startEventNames endEventNames]';
labels.name = eventNames(:);

% Save the event times:
StartEndTimes = (Markers(:,[2 3])-1)';
labels.t_ms  = t_ms(StartEndTimes(:));

end