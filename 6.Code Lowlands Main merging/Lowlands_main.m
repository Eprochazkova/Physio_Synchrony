%% Lowlands Data Analysis:
%
% This script processes a single dyad folder. -Elio Sjak-Shie, 2017
%
%==========================================================================
% Snapshots:
%
%  Note: This script looks for snapshots using the following convention:
%   FILENAME_(F_Imp|F_Int_(V|N)|S_Int_(V|N)).(png|jpg)
%  where FILENAME is the participant code; e.g., D01_M01.
%
%  The scripts expects to find three snapshots per participant, and stops
%  if it doesn't.
%
%==========================================================================
% Files:
%
% The Toolbox requires that the following files be present in each dyad
% folder:
%   > Exactly two .acq files.
%
%   > Per person (D01_M01 example):
%     > One .tsv called D01_M01.tsv
%     > One full stream movie, called D01_M01.mp4
%     > One .json file, called D01_M01.json
%     > The offset files and the snapshot images.




%% Initialize:

% Clean up:
clc; close all; clear all; %#ok<*CLALL>

% Add paths:
addpath(genpath('.\code'));
addpath(genpath('.\ExtraCode'));


%% Parameters:

% Names of the scored events:

%   Section Name:        Section Start Tag:           Section End Tag:
SECTION_TAGS = {...
    'F_Imp'              'F_Imp_Start'                'F_Imp_End';... 
    'F_Int'              'F_Int_Start'                'F_Int_End';...
    'S_Int'              'S_Int_Start'                'S_Int_End';...
%     ...
    'Laugh'              'Laughter_Start'             'Laughter_End';...
    'Smile'              'Smile_Start'                'Smile_End';...
    'OpenBodyPosition'   'Open_Body_Position_Start'   'Open_Body_Position_End';...
    'ClosedBodyPosition' 'Closed_Body_Position_Start' 'Closed_Body_Position_End';...
    'Head_Shake'         'Head_Shake_Start'           'Head_Shake_End';...
    'Hand_Shake'         'Hand_Shake_Start'           'Hand_Shake_End';...
    ...
    'Touch_Face'          'Touch_Face_Start'          'Touch_Face_End'     
    };

% The dyad settings (the filenames are determined dynamically):
dyad = DyadManager;
dyad.Biopac_1.chansToExtract    = [0:3 12];       % Zero-base
dyad.Biopac_2.chansToExtract    = [0:1 10];       % Zero-base
dyad.Biopac_1.syncMarkerChannel = 5;              % One-base
dyad.Biopac_2.syncMarkerChannel = 3;              % One-base
dyad.Tobii_1.SectionLabels      = SECTION_TAGS;
dyad.Tobii_2.SectionLabels      = SECTION_TAGS;
dyad.Tobii_1.biopac1SyncChannel = 3;              % One-base
dyad.Tobii_2.biopac1SyncChannel = 4;              % One-base


%% Macros:

SEP   = [repmat('-',1,80) '\n'];
NL_L1 = '  >  ';
NL_L2 = '     #  ';

%% Specify Folder:
% Specify the dyad folder containing all the necessary files.

% Get directory:
dyadDir = uigetdir('J:\ResearchData\FSW\Psychologie Cognitieve\CoPAN\Research Projects\Ongoing Projects\Lowlands\Glasses\Final Merged data','Pick the Dyad folder');
dyadName = dyadDir(find(dyadDir=='\',1,'last')+1:end);
fprintf([SEP NL_L1 'Analyzing folder: %s.\n' SEP],dyadName);
if isempty(dyadDir)|| isempty(dyadName)
    return
end
dyadDir = [dyadDir '\'];
acqFiles = dir([dyadDir '*.acq']);
assert(length(acqFiles)==2,'Total .acq files inside folder must be 2!');
dyad.dyadDir = dyadDir;


%% Specify Filenames:
% This script assigns the data to 'PPN1' (Biopac_1 & Tobii_1) and 'PPN2',
% with PPN1 always being the master time keeper. To determine which file is
% PPN1, the script looks at the amount of channels in the file.

% Read the headers from file 1:
[header, ~, ~, ~, ~, ~] = acqGet([dyadDir acqFiles(1).name],[]);

% Depending on the structure of file 1, read the data for PPN1 and PPN2:
if length(header)==13
    dyad.Biopac_1.filename = acqFiles(1).name;
    dyad.Biopac_2.filename = acqFiles(2).name;
    dyad.Tobii_1.filename  = [acqFiles(1).name(1:end-3) 'tsv'];
    dyad.Tobii_2.filename  = [acqFiles(2).name(1:end-3) 'tsv'];
elseif length(header)==11
    dyad.Biopac_1.filename = acqFiles(2).name;
    dyad.Biopac_2.filename = acqFiles(1).name;
    dyad.Tobii_1.filename  = [acqFiles(2).name(1:end-3) 'tsv'];
    dyad.Tobii_2.filename  = [acqFiles(1).name(1:end-3) 'tsv'];
else
    error('Something wrong the the acq file');
end
fileMissingErr = @(fn) assert(exist(fn ,'file')==2 ...
    ,'The following file is missing: %s.',fn);
fileMissingErr([dyad.dyadDir dyad.Tobii_1.filename]);
fileMissingErr([dyad.dyadDir dyad.Tobii_2.filename]);


%% Process the Data:

% Load, process and sync:
dyad.loadBiopacs();
dyad.loadTobii();

% Set which snapshots to process:
expectedSnapshots = 3;
getSnapFormat = @(tobiiName) [ dyad.(tobiiName).filename(1:7) ...
    '_(F_Imp|F_Int_(V|N)|S_Int_(V|N)).(png|jpg|PNG)'];
getSnaps = @(tobiiName) regexp(dyad.(tobiiName).dataObj.getSnapshotNames...
    ,getSnapFormat(tobiiName),'match');
snaps1 = getSnaps('Tobii_1');
dyad.Tobii_1.snapshotNames = vertcat(snaps1{:});
snaps2 = getSnaps('Tobii_2');
dyad.Tobii_2.snapshotNames = vertcat(snaps2{:});
if length(dyad.Tobii_1.snapshotNames)<expectedSnapshots
    fprintf(2,SEP);
    fprintf(2 ...
    ,['\n\nERROR :(\nOnly found the following snapshot(s) for'...
    ' %s (instead of %i):\n']...
        ,dyad.Tobii_1.dataObj.name,expectedSnapshots);
    fprintf(2,'%s\n',dyad.Tobii_1.snapshotNames{:});
    fprintf(2,'\nAvailable snapshots in %s:\n',dyad.Tobii_1.dataObj.name);
    fprintf(2,'%s\n',dyad.Tobii_1.dataObj.getSnapshotNames{:});
    fprintf(2,SEP);
end
if length(dyad.Tobii_2.snapshotNames)<expectedSnapshots
    fprintf(2,SEP);
    fprintf(2 ...
    ,['\n\nERROR :(\nOnly found the following snapshot(s) for'...
    ' %s (instead of %i):\n']...
        ,dyad.Tobii_2.dataObj.name,expectedSnapshots);
    fprintf(2,'%s\n',dyad.Tobii_2.snapshotNames{:});
    fprintf(2,'\nAvailable snapshots in %s:\n',dyad.Tobii_2.dataObj.name);
    fprintf(2,'%s\n',dyad.Tobii_2.dataObj.getSnapshotNames{:});
    fprintf(2,SEP);
end
if length(dyad.Tobii_1.snapshotNames)<expectedSnapshots ...
        ||length(dyad.Tobii_2.snapshotNames)<expectedSnapshots
    return
end

% Process the Tobiis:
dyad.processTobii();
dyad.unloadTobiiRawData();
dyad.calculateOffsets();


%% Generate Synced dataset:

% Make data:
[ data, physioDataInfo ] = makeSyncedDataStruct(dyad);    

% Remove all the syncPortHigh and syncPortLow labels:
data = removeSyncMarkerLabels(data);

try
% Add offsets:
for ETindx = 1:2
    offsets = struct();
    for curSnapIndx = 1:3
        curSnapName = data.eyeTracking(ETindx)...
            .gazeData(curSnapIndx).snapshotName;
        fid = fopen([dyad.dyadDir curSnapName(1:end-4) '.txt']);
        fileCloser = onCleanup(@() close(fid));
        if fid==-1
            continue
        end
        textFile = textscan(fid,'%s%f');
        offsets(curSnapIndx).offsets  = [textFile{2}];
        offsets(curSnapIndx).snapName = curSnapName;
        delete(fileCloser);
    end
    data.eyeTracking(ETindx).metadata.offsets = offsets;
end
catch
end

% Save file:
physioDataFn = [dyad.dyadDir dyadName '.physioData'];
if exist(physioDataFn,'file')==2
    save(physioDataFn,'data','physioDataInfo','-append');
else
    save(physioDataFn,'data','physioDataInfo');
end
fprintf('\nDyad Physiodata file saved to: %s.\n\n',physioDataFn)

% return

[hFig, WMP1, WMP2] = awesomeSyncPlayer(dyad);
fprintf('Done\n\n')

return



