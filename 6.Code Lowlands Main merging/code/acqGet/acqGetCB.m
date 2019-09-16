function acqGetCB(status, a, b, c, d)
% Callback function for a running acqGet mex file. This function is called
% intermittently to update the console (or a GUI).
% 
% The callback function is called using a 'status' argument, which defines
% its behavior, and variable input arguments (varargin) with the necessary
% info.
%
% status(arguments):
%
%         openingFile()
%         openedFile(version, mpDevID, numChannels, sampleRate)
%         doingChan(curChanIter,curChanIndx,totalChans)
%         doneChan(curChanIter,curChanIndx,totalChans)
%         doingMarker(curMarkerIter,totalMarkers)
%         doneMarker(curMarkerIter,totalMarkers)
%         complete()

% Note that at most 4 arguments can be provided by the C backend

return

switch status
    case 'openingFile'
        fprintf('\nOpening File');
        
        %** Update GUI**
        
    case 'openedFile'
        fprintf('\nFile version: %i, Device ID: %i, Number of channels: %i, Sample rate: %i', a,b,c,d); 
        
        %** Update GUI**
        
        
    case 'doingChan' % Only called when data is being extracted from the channel, not when just checking its info.
        fprintf('\nProcessing channel %i (indx = %i) of %i ...', a, b, c);
        
        %** Update GUI**
        
        
    case 'doneChan' % Only called when data is being extracted from the channel, not when just checking its info.
        fprintf(' done');
        
        %** Update GUI**
        
    case 'doingMarker' 
        fprintf('\nProcessing %i marker(s)', a);
        
    case 'doneMarker' 
        
    case 'complete'
        fprintf('\nFinished processing channels and markers\n')
        
        %** Update GUI**
        
    otherwise
        fprintf('\nUnknown status');
end
end