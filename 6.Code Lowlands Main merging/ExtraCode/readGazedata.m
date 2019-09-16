function [dataArray,headers] = readGazedata(fn)
% Reads E-Prime gazedata file.
%
%  Elio Sjak-Shie

nNumericDataColumns = 24;

try
    fileID         = fopen(fn,'r');
    fileCloser     = onCleanup(@() fclose(fileID));
    if fileID ~= -1
        headerCell   = textscan(fileID,'%[^\n\r]',1);
        headers      = strsplit(headerCell{1}{1},'\t');
        assert(length(headers)>=nNumericDataColumns);
        dataArray      = textscan(fileID...
                ,[repmat('%f',1,nNumericDataColumns) ...
                repmat('%s',1,length(headers)-nNumericDataColumns)]...
        ,'Delimiter', '\t');

    else
        dataArray = [];
        fprintf(2,'Error opening file!\n');
        return
    end
    clear fileCloser;
catch ball
    dataArray = [];
    fprintf(2,'Error opening file! (ERROR: %s)\n\n',ball.message);
end
end
