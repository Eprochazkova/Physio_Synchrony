classdef EyeTrackingData < handle
    % EyeTrackingData - Class for managing eye tracking data.
    %
    %   obj = EyeTrackingData(filename,fileType[,name]) Initializes an
    %   instance and loads the raw data into the object.
    %
    %   Subsequently, use the following commands to process the object:
    %
    %     > Process the gazes per snapshot:
    %        processGaze(obj[,snapNames]);
    %
    %     > Process the eye diameters:
    %        processDiameters(obj);
    %
    %     > Create named sections between events:
    %        addEventSections(obj,SectionLabels);
    %
    %     > Create a physioData file compatible struct:
    %        data.eyeTracking = returnStruct(obj);
    %
    %    The script assumes the following data storage format:
    %
    %    Inside a single folder:
    %     > The .tsv data file, with the name: <fn>.tsv
    %
    %     > If applicable, the full video recording, with the name:
    %     <fn>.mp4. In addition, in applicable, the raw json file for
    %     determining the video latency, with the name: <fn>.json
    %
    %     > If applicable, per snapshot, the snapshot image with the name:
    %     <snapshotname> . Note the the snapshot name must contain the
    %     image extension.
    %
    %
    %     THIS SCRIPT IS STILL VERY MUCH IN DEVELOPMENT!
    %
    %
    %----------------------------------------------------------------------
    %   Part of the PhysioData Toolbox.
    %    Elio Sjak-Shie, Faculty of Social Sciences,
    %     Leiden University, 2017.
    %----------------------------------------------------------------------
    
    
    %% Properties:
    
    
    properties
        
        % filename - the name of the source file.
        filename = '';
        
        % name - name of the ET dataset.
        name     = '';
        
        % diameter - a scalar struct containing the time vector, in ms, and
        % the raw measured pupil diameters of the left and/or right eye.
        % The diameters should be in millimeters.
        diameter     = struct('t_ms',[],'L',[],'R',[]);
        
        % diameterUnit - The unit of the diameter.
        diameterUnit = 'mm'
        
        % gaze - n x 1 struct containing the n snapshots and their data.
        % The data consists of the snapshots: name, image, width, and
        % height. Additionally, the Gaze coordinates, fixation coordinates,
        % and, RoI hits, and metadata are saved. The RoI-struct is a k x 1
        % struct--for k RoI regions--containing the RoI's name in 'name',
        % and the start and end times of the hits, in milliseconds, in the
        % 'hit' field. The  h hits are saved in h x 2 matrix with the start
        % and end times as columns. The gazePoints and fixationPoints
        % fields are struct with times, in ms, and points, in XY
        % cooridnates.
        gazeData = struct('snapshotName',''...
            ,'snapshotImage',[]...
            ,'snapshotWidth',[]...
            ,'snapshotHeight',[]...
            ,'gazePoints',struct('t_ms',[],'XY',[])...
            ,'fixationPoints',struct('t_ms',[],'XY',[])...
            ,'RoI',struct('name',{},'hit',{})...
            ,'metadata',struct('name',{},'value',{}));
        
        % eventSections - n x 1 struct that holds n scored events. These
        % events are scored visually and are independent of the snapshots.
        % The struct is similar to the RoI struct in gazeData.
        eventSections = struct('name',{},'hit',{});
        
        % vidStream - this struct hold data about a single video that was
        % recording in sync with the eye tracking data.
        vidStream = struct('fullVid'...
            ,struct('relFilename','','timeCorrection',[]...
            ,'mmInfo',[])...
            ,'snapshotVids'...
            ,struct('snapshotName',{},'relFilename',{},'mmInfo',{}));
        
        % zeroTS - scalar double for holding the timestamp of the
        % first Tobii data row.
        zeroTS = [];
        
        % metadata -  blank struct for containing extra metadata.
        metadata  = struct();
        
        % raw_t_ms_max - double for holding the maximum time in the raw
        % dataset.
        raw_t_ms_max;
        
        % labels - labels.
        labels;
        
        % The following variables are for internal use only, and are not
        % returned by obj.returnStruct():
        dataType;
        rawHeaders;
        rawDataArray;
        raw_t_ms;
        
    end
    
    
    
    %% Methods:
    
    
    methods
        
        
        %==================================================================
        function obj = EyeTrackingData(filename,fileType,name)
            % Constructor
            %
            %    obj = EyeTrackingData([filename])
            
            % If a filename was specified, read the file:
            if nargin>0
                
                % Check number of inputs:
                narginchk(2,3);
                
                % Collect data from inputs:
                obj.filename = filename;
                if nargin<3
                    [~,name,~] = fileparts(filename);
                end
                obj.name     = name;
                
                % Process Tobii analyzer data:
                if strcmpi(fileType,'TobiiAnalyzerExport')
                    assert(strcmp(obj.filename(end-2:end),'tsv')...
                        ,['The TobiiAnalyzerExport option can only'...
                        ' be used with .tsv files.'])
                    obj.dataType = 'TobiiAnalyzerExport';
                    
                    % Read data:
                    printLine = consoleFeedback('L2'...
                        ,'Importing Tobii Data');
                    printLine('Reading .tsv file');
                    [dataArray,headers] = readTobiiGlassesData(...
                        obj.filename);
                    obj.rawDataArray    = dataArray;
                    obj.rawHeaders      = headers;
                    
                    % Generate the master time vector:
                    printLine('Processing data');
                    timeColIndx        = find(strcmp(headers...
                        ,'Recording timestamp'),1);
                    assert(~isempty(timeColIndx)...
                        ,['Cannot find a column named '...
                        '''Recording timestamp''']);
                    obj.raw_t_ms     = str2double(...
                        obj.rawDataArray{timeColIndx});
                    obj.zeroTS = obj.raw_t_ms(1);
                    obj.raw_t_ms = obj.raw_t_ms -obj.zeroTS;
                    obj.raw_t_ms_max = max(obj.raw_t_ms);
                    
                    % Process events: Find event column, and isolate the
                    % event rows.
                    printLine('Processing events');
                    eventsColIndx     = find(strcmp(headers,'Event'));
                    eventLog          = ~cellfun(@isempty...
                        ,dataArray{eventsColIndx});
                    
                    % Get event metadata:
                    obj.labels.name = dataArray{...
                        eventsColIndx}(eventLog);
                    obj.labels.t_ms = str2double(...
                        dataArray{timeColIndx}(eventLog));
                    printLine('done'...
                        ,'L3'...
                        ,{sprintf('File: %s.',obj.filename)...
                        sprintf('%i data rows imported.'...
                        ,length(obj.raw_t_ms))...
                        sprintf('%i events found.',sum(eventLog))...
                        });
                    
                    
                elseif strcmpi(fileType,'EPrimeGazedata')
                    % Process gazedata files:
                    
                    assert(strcmp(obj.filename(end-7:end),'gazedata')...
                        ,['The EPrimeGazedata option can only'...
                        ' be used with gazedata files.'])
                    obj.dataType = 'EPrimeGazedata';
                    
                    % Read data:
                    printLine = consoleFeedback('L2'...
                        ,'Importing Tobii Data');
                    printLine('Reading .gazedata file');
                    [dataArray,headers] = readGazedata(obj.filename);
                    
                    obj.rawDataArray    = dataArray;
                    obj.rawHeaders      = headers;
                    
                    % Generate the master time vector. Note, the gazedata
                    % contains both the EyeTrackers timestamps, and
                    % E-Primes timestamp, in the RTTime column, it is
                    % advisable to the the former, as the E-Prime time is
                    % not uniform. This has no effect on the data, since
                    % everything is recoreded the the TETTime. However,
                    % when comparing the times with the E-Prime Edat files,
                    % care should be taken regarding the sync, especially
                    % in regards to drift.
                    printLine('Processing data');
                    timeColName = 'TETTime';
                    timeColIndx        = find(strcmp(headers...
                        ,timeColName),1);
                    assert(~isempty(timeColIndx)...
                        ,['Cannot find a column named '...
                        '''Recording timestamp''']);
                    obj.raw_t_ms     = obj.rawDataArray{timeColIndx};
                    obj.zeroTS = obj.raw_t_ms(1);
                    obj.raw_t_ms = obj.raw_t_ms -obj.zeroTS;
                    obj.raw_t_ms_max = max(obj.raw_t_ms);
                    
                    % Process events: Find event column, and isolate the
                    % event rows.
                    printLine('Processing events');
                    obj.labels = trialToEvents(obj.raw_t_ms...
                        , dataArray{strcmp(headers,'TrialId')});
                    printLine('done'...
                        ,'L3'...
                        ,{sprintf('%i data rows imported.'...
                        ,length(obj.raw_t_ms))...
                        sprintf('%i events found.'...
                        ,length(obj.labels.name))...
                        });
                    
                else
                    error('inputs should be.....');
                end
            end
            
        end
        
        
        %==================================================================
        function checkLoad(obj)
            if isempty(obj.rawHeaders)...
                    ||isempty(pobj.rawHeaders)...
                    ||isempty(pobj.rawdataArray);
                error('This object does not contain data!');
            end
        end
        
        
        %==================================================================
        function snapNames = getSnapshotNames(obj)
            % Gets the name of all the snapshots in the file.
            
            % Look for the snapshots names in the .tsv file:
            if strcmp(obj.dataType,'TobiiAnalyzerExport');
                
                % Get the snapshot names form several columns amd check
                % accordance:
                findSnaps = @(colName) regexp(obj.rawHeaders...
                    ,[colName ' \[(.*)\]'],'tokens','once');
                listSnaps = @(snapCell) vertcat(snapCell{:});
                snaps     = @(colName) listSnaps(findSnaps(colName));
                snap1     = snaps('Width');
                assert(isequal(snaps('Width'),snaps('Height')...
                    ,snaps('Mapped gaze data X')...
                    ,snaps('Mapped gaze data Y'))...
                    ,'There is something wrong with the snapshots!');
                snapNames = snap1;
            elseif strcmp(obj.dataType,'EPrimeGazedata');
                snapNames = {'fullRecording'};
            else
                keyboard;
            end
            
        end
        
        
        %==================================================================
        function processGaze(obj,snapNames)
            
            % Process input:
            if nargin==1||isempty(snapNames)
                snapNames = obj.getSnapshotNames;
            end
            if size(snapNames,2)>1
                error('Snapnames must be single column format.');
            end
            
            %             if
            %             ~all(ismember(snapNames,getSnapshotNames(obj)))
            %                 disp(' '); disp('Available snapshots:');
            %                 disp(getSnapshotNames(obj)); error('Not all
            %                 snapshots are present in file.');
            %             end
            
            consoleFeedback('L2'...
                ,'Processing Gaze from the following Snapshot(s):'...
                ,'L3',snapNames);
            
            printLine = consoleFeedback('L2','Processing Snapshot(s)');
            
            % Get the path:
            [filepath,~,~] = fileparts(obj.filename);
            
            % act accoring to the datatype:
            if strcmp(obj.dataType,'TobiiAnalyzerExport')
                
                % Process snapshots:
                for curSnapIndx = 1:size(snapNames,1)
                    
                    % Preprocess loop params:
                    curSnapName = snapNames{curSnapIndx};
                    
                    printLine(curSnapName)
                    
                    % Save snapshot metadata:
                    obj.gazeData(curSnapIndx).snapshotName = curSnapName;
                    obj.gazeData(curSnapIndx).snapshotWidth ...
                        = str2double(...
                        obj.rawDataArray{~cellfun(@isempty...
                        ,strfind(obj.rawHeaders...
                        ,['Width [' curSnapName ']']))}(1));
                    obj.gazeData(curSnapIndx).snapshotHeight ...
                        = str2double(...
                        obj.rawDataArray{~cellfun(@isempty...
                        ,strfind(obj.rawHeaders...
                        ,['Height [' curSnapName ']']))}(1));
                    
                    % Try to get the snapshot image:
                    try
                        obj.gazeData(curSnapIndx).snapshotImage ...
                            = imread([filepath '\' curSnapName]);
                    catch
                        fprintf(2,['\nCould not load the snapshot'...
                            ' image: %s\n\n']...
                            ,curSnapName);
                    end
                    
                    % Get the gaze and fixation columns:
                    fixXY_ColIndx = ...
                        [find(~cellfun(@isempty,regexp(obj.rawHeaders...
                        ,['Mapped fixation X.*' curSnapName])))...
                        find(~cellfun(@isempty,regexp(obj.rawHeaders...
                        ,['Mapped fixation Y.*' curSnapName])))];
                    gazePoints_ColIndx = ...
                        [find(~cellfun(@isempty,regexp(obj.rawHeaders...
                        ,['Mapped gaze data X.*' curSnapName])))...
                        find(~cellfun(@isempty,regexp(obj.rawHeaders...
                        ,['Mapped gaze data Y.*' curSnapName])))];
                    
                    % Process gazes:
                    noGazedataRows = cellfun(@(A,B) ...
                        isempty(A)||isempty(B)...
                        ,obj.rawDataArray{gazePoints_ColIndx(1)}...
                        ,obj.rawDataArray{gazePoints_ColIndx(2)});
                    obj.gazeData(curSnapIndx).gazePoints ...
                        = struct('t_ms',obj.raw_t_ms(~noGazedataRows)...
                        ,'XY',str2double(...
                        horzcat(obj.rawDataArray{gazePoints_ColIndx(1)}...
                        (~noGazedataRows)...
                        ,obj.rawDataArray{gazePoints_ColIndx(2)}...
                        (~noGazedataRows))));
                    
                    % Process Fixations:
                    noFixdataRows = cellfun(@(A,B) ...
                        isempty(A)||isempty(B)...
                        ,obj.rawDataArray{fixXY_ColIndx(1)}...
                        ,obj.rawDataArray{fixXY_ColIndx(2)});
                    obj.gazeData(curSnapIndx).fixationPoints ...
                        = struct('t_ms',obj.raw_t_ms(~noFixdataRows)...
                        ,'XY',str2double(...
                        horzcat(obj.rawDataArray{fixXY_ColIndx(1)}...
                        (~noFixdataRows)...
                        ,obj.rawDataArray{fixXY_ColIndx(2)}...
                        (~noFixdataRows))));
                    
                    % % Plot
                    % plotter = @(XY) plot(...
                    %     XY(:,1)+(4*rand(size(XY,1),1))-2,...
                    %     XY(:,2)+(4*rand(size(XY,1),1))-2,'x');
                    % plotter(obj.gazeData(curSnapIndx).fixationPoints.XY)
                    % hold on;
                    % plotter(obj.gazeData(curSnapIndx).gazePoints.XY)

                    % Check:
                    % X = [obj.rawDataArray{fixXY_ColIndx} obj.rawDataArray{gazePoints_ColIndx}];;
                    % X(~noGazedataRows|~noFixdataRows,:)
                   
                    % Process RoIs:
                    RoIHeadersNameCell = regexp(obj.rawHeaders...
                        ,['AOI hit \[' curSnapName ' - (.*)\]']...
                        ,'tokens','once');
                    RoIHeadersIndx = find(~cellfun(@isempty...
                        ,RoIHeadersNameCell));
                    RoIHeadersName = vertcat(RoIHeadersNameCell{:});
                    obj.gazeData(curSnapIndx).RoI = struct(...
                        'name',RoIHeadersName...
                        ,'hit',{[]});
                    
                    % Loop through RoIs:
                    for RoI_Indx = 1:length(RoIHeadersIndx);
                        obj.gazeData(curSnapIndx).RoI(RoI_Indx).hit ...
                            = hitBoolToMatrix(...
                            obj.rawDataArray{RoIHeadersIndx...
                            (RoI_Indx)},obj.raw_t_ms);
                    end
                end
                
            elseif strcmp(obj.dataType,'EPrimeGazedata')
                
                    % Get current snapshot name (the only snap):
                    curSnapIndx = 1;
                    curSnapName = snapNames{1};
                    printLine(curSnapName)
                    
                    % Save snapshot metadata:
                    obj.gazeData(curSnapIndx).snapshotName = curSnapName;
                    
                    % the gazedata does not report the screen width, so
                    % just guess it for now:
                    Cursor.X =  obj.rawDataArray{strcmp(obj.rawHeaders...
                        ,'CursorX')};
                    Cursor.Y =  obj.rawDataArray{strcmp(obj.rawHeaders...
                        ,'CursorY')};
                    validGaze = Cursor.X>0&Cursor.Y>0;
                    estimaterange  = @(d) round(median(Cursor.(d)...
                        (validGaze)...
                        ./mean([obj.rawDataArray{strcmp(obj.rawHeaders...
                        ,[d 'GazePosLeftEye'])}(validGaze)...
                        obj.rawDataArray{strcmp(obj.rawHeaders...
                        ,[d 'GazePosRightEye'])}(validGaze)],2)));                    
                    obj.gazeData(curSnapIndx).snapshotWidth ...
                        = estimaterange('X');
                    obj.gazeData(curSnapIndx).snapshotHeight ...
                       = estimaterange('Y');
                                        
                    % Process gazes:
                    obj.gazeData(curSnapIndx).gazePoints ...
                        = struct('t_ms',obj.raw_t_ms(validGaze)...
                        ,'XY',[Cursor.X(validGaze) Cursor.Y(validGaze)]);
                    
                    % Process RoIs:
                    
                    % Not currently supported for gazedata files.
            else
                keyboard;
                
            end
            printLine('done');
        end
        
        
        %==================================================================
        function visualize(~)
            keyboard % Not yet iplmented
        end
        
        
        %==================================================================
        function processDiameters(obj)
            % Processes the diameter data inside the EyeTrackingData
            % object.
            
            printLine = consoleFeedback('L2'...
                ,'Processing Pupil Diameters');
            
            if strcmp(obj.dataType,'TobiiAnalyzerExport')
                
                printLine('Converting');
                
                % Get the index of the diameter columns:
                diamLeftRightCols    = [find(strcmp(obj.rawHeaders...
                    ,'Pupil diameter left'),1)...
                    find(strcmp(obj.rawHeaders,'Pupil diameter right'),1)];
                assert(length(diamLeftRightCols)==2,['No diameter data'...
                    ' found in the file']);
                
                % Get the rows without any diameter data:
                noDiamData     = cellfun(@(A,B) isempty(A)&&isempty(B)...
                    ,obj.rawDataArray{diamLeftRightCols(1)}...
                    ,obj.rawDataArray{diamLeftRightCols(2)});
                
                % Extract the relevant data, and convert to double:
                toDub     = @(ii) str2double(strrep(obj.rawDataArray{ii}...
                    (~noDiamData),',','.'));
                obj.diameter.t_ms = obj.raw_t_ms(~noDiamData);
                obj.diameter.L    = toDub(diamLeftRightCols(1));
                obj.diameter.R    = toDub(diamLeftRightCols(2));
                
            elseif strcmp(obj.dataType,'EPrimeGazedata')
                
                printLine('Converting');
                
                % Get the index of the diameter columns:
                diamLeftRightCols    = [find(strcmp(obj.rawHeaders...
                    ,'DiameterPupilLeftEye'),1)...
                    find(strcmp(obj.rawHeaders...
                    ,'DiameterPupilRightEye'),1)];
                assert(length(diamLeftRightCols)==2,['No diameter data'...
                    ' found in the file']);
                
                diamsFull.L = obj.processGazedataDiameters('Left');
                diamsFull.R = obj.processGazedataDiameters('Right');
                noDiamData  = isnan(diamsFull.L)...
                    &isnan(diamsFull.R);

                % Extract the relevant data, and save to object:
                obj.diameter.t_ms = obj.raw_t_ms(~noDiamData);
                obj.diameter.L    = diamsFull.L(~noDiamData);
                obj.diameter.R    = diamsFull.R(~noDiamData);
                
            end
            
            printLine('done','L3'...
                ,sprintf('%i rows contained pupil diameter data.'...
                ,sum(~noDiamData)));
            
        end
        
        
        %==================================================================
        function diaOut = processGazedataDiameters(obj,eyeStr)
            % helper function for extracting an eye's diameter data from
            % gazedata.
            
            % Acceptable validity scores:
            okValidity = [0 1];
            
            % Get the index of the diameter columns:
            diaColIndx = find(strcmp(obj.rawHeaders...
                ,['DiameterPupil' eyeStr 'Eye']),1);
            diaValidIndx = find(strcmp(obj.rawHeaders...
                ,['Validity' eyeStr 'Eye']),1);
            assert(~isempty(diaColIndx)&& ~isempty(diaValidIndx)...
                ,['No diameter data'...
                ' found in the file']);
            
            % Remove non-valid data:
            diaOut = obj.rawDataArray{diaColIndx};
            diaOut(~ismember(obj.rawDataArray{diaValidIndx}...
                ,okValidity)) = NaN;
        
        end
        
        
        %==================================================================
        function s = returnStruct(obj, offsetSec, ~)
            
            % Collect the fields to export:
            for f = {'filename' 'name' 'diameter' 'gazeData'...
                    'eventSections' 'labels' 'diameterUnit' 'vidStream'...
                    'dataType' 'raw_t_ms_max' 'metadata'};
                s.(f{1}) = obj.(f{1});
            end
            
            % Shift the signal if an offset is given:
            if nargin>1

                % Offset:
                offset_ms = offsetSec*1000;
                
                % Process diameter data:
                s.diameter.t_ms = s.diameter.t_ms+offset_ms;
                
                % Process gazeData:
                for ii = 1: length(s.gazeData)
                    s.gazeData(ii).gazePoints.t_ms ...
                        = s.gazeData(ii).gazePoints.t_ms+offset_ms;
                    s.gazeData(ii).fixationPoints.t_ms ...
                        = s.gazeData(ii).fixationPoints.t_ms+offset_ms;
                    for kk = 1: length(s.gazeData(ii).RoI)
                        s.gazeData(ii).RoI(kk).hit...
                            = s.gazeData(ii).RoI(kk).hit + offset_ms;
                    end
                end
                clear ii kk
                
                % Process eventSections:
                for ii = 1:length(s.eventSections)
                    s.eventSections(ii).hit ...
                        =  s.eventSections(ii).hit + offset_ms;
                end
                clear ii
                
                % Process labels:
                s.labels.t_ms = s.labels.t_ms+offset_ms;
                
                % Process raw_t_ms_max:
                s.raw_t_ms_max = s.raw_t_ms_max+offset_ms;
                
                % Add description:
                s.syncDesc = sprintf(['Original signal shifted by'...
                    ' %.4f s.']...
                    ,offsetSec);
                
            end
            
        end
        
        
        %==================================================================
        function registerFullVid(obj, vidFilename,delay)
            
            % Force that only the filename and extension are saved:
            if nargin==1||isempty(vidFilename)
                [~, fn, ~ ] = fileparts(obj.filename);
                vidFilename = [fn '.mp4'];
            else
                [~,fn,ext] =  fileparts(vidFilename);
                vidFilename = [fn ext];
            end
            
            obj.vidStream.fullVid.relFilename = vidFilename;
            
            if nargin>2
                obj.vidStream.fullVid.timeCorrection = delay;
            end
            
        end
        
        
        %==================================================================
        function varargout = addEventSections(obj,sectionTags)
            % addEventSections  Creates sections from events.
            %
            %    addEventSections(obj,sectionTags) Processes the
            %    sectionTags cell and the objects events, and converts
            %    periods between start and end tags to named sections. The
            %    sections are defined in sectionTags, which must have the
            %    following format: The first columns is the section name
            %    (must be a valid variable name); the second column is the
            %    event that marks the start of the section; and, the last
            %    columns indicates the end.
            %
            %    s = addEventSections(obj,sectionTags) does not save the
            %    sections to the object, but returns a struct instead.
            
            % Keep or disregard orphans (sections without ends):
            keepOrphan = true;
            
            % Check input:
            assert(size(sectionTags,2)==3);
            assert(size(sectionTags,1)>=1);
            
            % Preallocate:
            nTags           = size(sectionTags,1);
            startEndTimes   = cell(nTags,1);
            
            for curTagRow = 1:nTags
                
                % Find the start and end times of the interval:
                intervalStart  = obj.labels.t_ms(...
                    strcmp(obj.labels.name...
                    ,sectionTags{curTagRow,2}));
                intervalEnd  = obj.labels.t_ms(...
                    strcmp(obj.labels.name...
                    ,sectionTags{curTagRow,3}));
                
                % Try fixing the case where the last end in missing:
                if keepOrphan&&length(intervalStart)==length(intervalEnd)+1
                    intervalEnd(end+1) = obj.raw_t_ms_max; %#ok<AGROW>
                    if size(intervalEnd,2)>1
                        intervalEnd = intervalEnd';
                    end
                end
                % Check that there are equal number of starts and ends, and
                % the all starts occur before their respective ends:
                if length(intervalStart)~=length(intervalEnd)
                    fprintf(2,['\nSection error in file %s:\nUnequal' ...
                        ' amounts of start and end events.\nNo ''%s'''...
                        ' sections created.\n\n'] ...
                        ,obj.name...
                        ,sectionTags{curTagRow,1});
                    fprintf(2,'%s (%i events):\n'...
                        ,sectionTags{curTagRow,2}...
                        ,length(intervalStart));
                    fprintf(2,'%0.1f s\n',intervalStart/1000);
                    disp('       ');
                    fprintf(2,'%s (%i events):\n'...
                        ,sectionTags{curTagRow,3}...
                        ,length(intervalEnd));
                    fprintf(2,'%0.1f s\n',intervalEnd/1000);
                    disp('       ');
                    continue
                end
                startAfterEndIsNoGood = intervalStart>=intervalEnd;
                if any(startAfterEndIsNoGood)
                    fprintf(2,['\nSection error in file %s:\nStart' ...
                        ' after end detected'...
                        ' (durations must be positive).\nNo ''%s'''...
                        ' sections created.\n\n'] ...
                        ,obj.name...
                        ,sectionTags{curTagRow,1});
                    fprintf(2,'%20s:   %20s:   %20s:\n'...
                        ,sectionTags{curTagRow,2}...
                        ,sectionTags{curTagRow,3}...
                        ,'Duration');
                    fprintf(2,'%20.1f   %20.1f   %20.1f\n'...
                        ,[intervalStart intervalEnd ...
                        (intervalEnd-intervalStart)]'./1000);
                    disp('       ');
                    continue
                end
                
                % Delete sections that are shorter than 2 ms:
                dur = (intervalEnd-intervalStart);
                intervalEnd(dur<2)   = [];
                intervalStart(dur<2) = [];
                
                % Check if all sections end before the next begins:
                if (length(intervalStart)>1)...
                        &&any(intervalEnd(1:(end-1))>intervalStart(2:end))
                    fprintf(2,['\nSection error in file %s:\n' ...
                        'Overlapping sections detected'...
                        ' (delay of start must be positive).\nNo ''%s'''...
                        ' sections created.\n\n'] ...
                        ,obj.name...
                        ,sectionTags{curTagRow,1});
                    fprintf(2,'%20s:   %20s:   %20s:\n'...
                        ,sectionTags{curTagRow,2}...
                        ,sectionTags{curTagRow,3}...
                        ,'startDelay');
                    fprintf(2,'%20.1f   %20.1f   %20.1f\n'...
                        ,[intervalStart intervalEnd ...
                        [NaN;...
                        (intervalStart(2:end)...
                        -intervalEnd(1:(end-1)))...
                        ]...
                        ]'./1000);
                    disp(' ');
                    continue
                end
                
                startEndTimes(curTagRow,:) ...
                    = {[intervalStart intervalEnd]};
            end
            
            % Choose return or save behavior:
            data = struct('name',sectionTags(:,1)...
                ,'hit',startEndTimes...
                ,'desc',strcat({'From '''}...
                ,sectionTags(:,2),''' to ''',sectionTags(:,3),'''.'));
            if nargout == 0
                obj.eventSections = data;
                varargout = {};
            elseif nargout == 1
                varargout{1} = data;
            else
                error('Incorrect number of output args.');
            end
            
        end
        
        
        
    end
    
end