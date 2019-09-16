function [dataArray,headers] = readTobiiGlassesData(fn)
% Reads Tobii Glasses Data (from new and old analyzer software).
%
%  Elio Sjak-Shie


try
    % Determine file encoding:
    fileID         = fopen(fn,'r');
    fileCloser     = onCleanup(@() fclose(fileID));
    if fileID ~= -1
        headerString   = textscan(fileID,'%[^\n\r]',1);
        if isequal(double(headerString{1}{1}(1:2)),[255 254]);
            fileEncoding = 'UTF16';
        else
            fileEncoding = 'UTF8';
        end
    else
        dataArray = [];
        fprintf(2,'Error opening file!\n');
        return
    end
    clear fileCloser;
    
    % Run correct data import function:
    switch fileEncoding
        case 'UTF8'
            [dataArray,headers] =  readUTF8(fn);
        case 'UTF16'
            [dataArray,headers] =  readUTF16(fn);
    end
    
    % Correct data if the final row has missing data:
    dataArrayChannelSizes = cellfun(@length,dataArray');
    tooShort = dataArrayChannelSizes<max(dataArrayChannelSizes);
    assert(max(dataArrayChannelSizes)-min(dataArrayChannelSizes)<=1 ...
        ,'Unexpected columns size.\n\n');
    for curTooShort = find(tooShort)'
        dataArray{curTooShort} = [dataArray{curTooShort};{''}];
    end
    
catch ball
    dataArray = [];
    fprintf(2,'Error opening file! (ERROR: %s)\n\n',ball.message);
end
end


%==========================================================================
function [dataArray,headers] = readUTF8(fn)
%Read file: (it may be UTF16-LE)
fileID         = fopen(fn,'r');
fileCloser     = onCleanup(@() fclose(fileID));
if fileID ~= -1
    headerString   = textscan(fileID,'%[^\n\r]',1);
    headers        = strsplit(headerString{1}{1},'\t');
    headers(end)   = [];
    nCols          = length(headers);
    dataArray      = textscan(fileID, repmat('%s',1,nCols)...
        ,'Delimiter', '\t');
else
    dataArray = [];
    fprintf(2,'Error opening file!\n');
    return
end
clear fileCloser;
end

%==========================================================================
function [dataArray,headers] = readUTF16(fn)
%Read file: (it may be UTF16-LE)

warning('off','MATLAB:iofun:UnsupportedEncoding')
fileID         = fopen(fn,'r', 'l', 'UTF16-LE');
fileCloser     = onCleanup(@() fclose(fileID));
if fileID ~= -1
    headerString   = textscan(fileID,'%[^\n\r]',1);
    headers        = strsplit(headerString{1}{1},'\t');
    headers(end)   = [];
    headers{1}(1)  = []; % Removes the UTF-16 tag
    nCols          = length(headers);
    dataArray      = textscan(fileID, repmat('%s',1,nCols)...
        ,'Delimiter', '\t');
else
    dataArray = [];
    fprintf(2,'Error opening file!\n');
    return
end
clear fileCloser;
warning('on','MATLAB:iofun:UnsupportedEncoding');
end