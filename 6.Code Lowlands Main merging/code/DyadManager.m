classdef DyadManager < handle
    % DyadManager Manages dyadic physiological and eye tracking data.
    %
    %   This class manages one or two Biopacs, and one or two Tobii Eye
    %   tracking datasets.
    %
    %   Script still in Development.
    %   - Elio
    
    %% Properties:
    
    % These properties need to be filled in before the dyad analyzer can
    % run:
    properties (Constant,Hidden)
        
       % Biopac properties:
       %
       %  > filename: the filename of the AcqKnowledge data file, for
       %  Biopac_2, leave empty to disable.
       %
       %  > chansToExtract: The channel indices (zero base) to extract from
       %  the acq file.
       %
       %  > syncMarkerChannel: The channels index (one base) with the
       %  markers (E-Prime).
       BiopacStruct = struct('filename',''...
           ,'chansToExtract',[]...
           ,'syncMarkerChannel',[]);
       
       
       % Biopac properties:
       %
       %  > filename: the filename of the Tobii data export file, for
       %  Tobii_2, leave empty to disable.
       %
       %  > SectionLabels: A cell structure indicating the sections to
       %  identify, see help of addEventSections\EyeTrackingData.
       %
       %  > biopac1SyncChannel: The channels index (one base) in Biopac 1
       %  with the current Tobii's markers.
       %
       %  > snapshotNames: the snapshots to extract. Leave empty to extract
       %  all snapshots from the file.
       TobiiStruct = struct('filename',''...
           ,'SectionLabels',{{}}...
           ,'biopac1SyncChannel',[]...
           ,'snapshotNames','');
    end
    
    properties
        
        % Dyad Directory:
        dyadDir   = '';
        
        % Person 1:
        Biopac_1  = DyadManager.BiopacStruct;
        Tobii_1   = DyadManager.TobiiStruct;
        
        % Person 2:
        Biopac_2  = DyadManager.BiopacStruct;
        Tobii_2   = DyadManager.TobiiStruct;
        
        % Sync data:
        globalTime   = [];
        globalBounds = [];
        
    end
    
    %% Methods:
    
    methods
        
        
        %==================================================================
        function obj = DyadManager()
            
        end
        
        
        %==================================================================
        function loadBiopacs(obj)
            % Loads one or two biopacs into the object.
                               
            if ~isempty(obj.Biopac_1.filename)
                doBiopac('Biopac_1');
            else
                error('No Biopacs to load!');
            end
            if ~isempty(obj.Biopac_2.filename)
                doBiopac('Biopac_2');
                assert(obj.Biopac_1.data.fs==obj.Biopac_2.data.fs...
                    ,'Sampling frequencies of both biopacs must agree.')
            end            
            function doBiopac(f)
                printLine = consoleFeedback('L2',['Loading ' f]);
                printLine('Reading file')
                [acqData.channelNames, acqData.unit, acqData.fs, ~, ~...
                    , acqData.channels] = acqGet(...
                    [obj.dyadDir obj.(f).filename]...
                    ,obj.(f).chansToExtract);
                
                obj.(f).data     = acqData;
                printLine('done','L3'...
                ,sprintf('File: %s.'...
                ,[obj.dyadDir obj.(f).filename]));
            end
        end
        
        
        %==================================================================
        function loadTobii(obj)
            if ~isempty(obj.Tobii_1.filename)
                doTobii('Tobii_1');
            else
                error('No Tobii filename')
            end
            if ~isempty(obj.Tobii_2.filename)
                doTobii('Tobii_2');
            end
            function doTobii(f)
                obj.(f).dataObj = EyeTrackingData(...
                    [obj.dyadDir obj.(f).filename]...
                    ,'TobiiAnalyzerExport');
            end
        end
        
        
        %==================================================================
        function processTobii(obj)
            % Adds and processes the Tobii data.
            %
            %  processTobii(obj,Tobii_1_fn,SectionLabels_1...
            %    [,Tobii_2_fn[,SectionLabels_2]]) process the Tobii file
            %    with the filename
            
            
            if ~isempty(obj.Tobii_1.filename)
                doTobii('Tobii_1');
            else
                return;
            end
            if ~isempty(obj.Tobii_2.filename)
                doTobii('Tobii_2');
            end
            function doTobii(f)
                if ~isfield(obj.(f),'dataObj')
                   error('Load Tobii Data First (loadTobii(obj))')
                end
                processGaze(obj.(f).dataObj,obj.(f).snapshotNames);
                processDiameters(obj.(f).dataObj);
                if ~isempty(obj.(f).SectionLabels)
                    addEventSections(obj.(f).dataObj...
                        ,obj.(f).SectionLabels);
                end
                
                vts = 0;
                
                % Try to get the delay using teh JSOn file:
                try
                    
                    % Parse JSON:
                    CStr = textread(...
                        [obj.dyadDir obj.(f).dataObj.name '.json'], '%s'...
                        , 'delimiter', '\n'); %#ok<DTXTRD>
                    regExpStr = ['{"ts":(?<ts>\d+),"s":(?<s>\d+)'...
                        ',"vts":(?<vts>\d+).*'];
                    JSON_cell = regexp(CStr,regExpStr,'names');
                    JSON_struct = arrayfun(@(s) ...
                        struct('ts',str2double(s.ts)...
                        ,'s',str2double(s.s),'vts'...
                        ,str2double(s.vts)),vertcat(JSON_cell{:}));
                    vts = [vertcat(JSON_struct.ts)...
                        vertcat(JSON_struct.vts)];
                    t0 = regexp(CStr{1},'{"ts":(\d+)','tokens');
                    vts(:,1) = vts(:,1)-str2double(t0{1});

                catch
                    fprintf(2,'\nCould not generate delay form JSON!\n\n');
                end
                
                registerFullVid(obj.(f).dataObj,'',vts);
                obj.(f).data = returnStruct(obj.(f).dataObj);
            end
            
        end
        
        
        %==================================================================
        function unloadTobiiRawData(obj)
            if ~isempty(obj.Tobii_1.filename)
                doTobii('Tobii_1');
            else
                error('No Tobii filename')
            end
            if ~isempty(obj.Tobii_2.filename)
                doTobii('Tobii_2');
            end
            function doTobii(f)
                obj.(f).dataObj.rawDataArray = [];
            end
        end
        
        
        %==================================================================
        function calculateOffsets(obj)
            
            % The threshold for an acceptable fit:
            fitThreshold       = 0.98;
            
            % The assumed voltage of the markers (doesnt affect xcorr):
            markerVolt         = 3.1;
            
            % Process Tobii 1:
            obj.Tobii_1.delay = calcTobiiOffset('Tobii_1');
            tobii1Del = obj.Tobii_1.delay.seconds;
            tobii1_tMax  = obj.Tobii_1.dataObj.raw_t_ms_max/1000;
            
            % Process Tobii 2:
            if ~isempty(obj.Tobii_2.filename)
                 obj.Tobii_2.delay = calcTobiiOffset('Tobii_2');
                 tobii2Del = obj.Tobii_2.delay.seconds;
                 tobii2_tMax   = obj.Tobii_2.dataObj.raw_t_ms_max/1000;
            else
                tobii2Del = 0;
                tobii2_tMax   =  inf;
            end
            
            % Calculate the Biopac offset only if a second biopac is
            % available and loaded:
            if ~isempty(obj.Biopac_2.filename)
                if ~isfield(obj.Biopac_2,'data')...
                        ||isempty(obj.Biopac_2.data)
                    error('Load Data First')
                end
                masterBiopac = obj.Biopac_1.data.channels{...
                    obj.Biopac_1.syncMarkerChannel};
                slaveBiopac = obj.Biopac_2.data.channels{...
                    obj.Biopac_2.syncMarkerChannel};
                [biopacC,biopacLags] = xcorr(masterBiopac,slaveBiopac);
                [~,biopacDelayIndx] = max(biopacC);
                biopacDelay = biopacLags(biopacDelayIndx);
                
                % Test fit (use 5 mins data):
                section = (1:(5*60*obj.Biopac_1.data.fs));
                biopacXcorrScore = corrcoef(...
                    masterBiopac(biopacDelay+section)...
                    ,slaveBiopac(section));
                assert(all(all(biopacXcorrScore>fitThreshold))...
                    ,'The Biopac Marker Signals do not match!');
                obj.Biopac_2.delay.seconds ...
                    = biopacDelay/obj.Biopac_1.data.fs;
                obj.Biopac_2.delay.samples = biopacDelay;
                biopac2Del = obj.Biopac_2.delay.seconds;
                biopac2L   = size(obj.Biopac_2.data.channels{1},1)...
                    /obj.Biopac_2.data.fs;
            else
                biopac2Del = 0;
                biopac2L   = inf;
            end
            
            % Calculate the section with all data:
            obj.globalBounds = [max([tobii1Del tobii2Del biopac2Del])...
                min([...
                ((size(obj.Biopac_1.data.channels{1},1)...
                /obj.Biopac_1.data.fs))...
                ...
                (biopac2Del+biopac2L)...
                ...
                (tobii1Del+tobii1_tMax)...
                ...
                (tobii2Del+tobii2_tMax)])];
            
            % Generate the global BIOPAC-1 based time vector:
            obj.globalTime = tGetFromDataStructField(obj.Biopac_1.data);
            
            
            %--------------------------------------------------------------
            function delay = calcTobiiOffset(f)
            % Synthesized the Tobii marker channel from the selfreported
            % events, and recorded marker channels:
            
            if ~isfield(obj.(f),'data')||~isfield(obj.(f),'dataObj')...
                    ||isempty(obj.(f).dataObj)...
                    ||isempty(obj.Biopac_1.filename)...
                    ||~isfield(obj.Biopac_1,'data')...
                    ||isempty(obj.Biopac_1.data)
                error('Load Data First')
            end
            
            % Use the fs of the biopac for syncing:
            syncFs = obj.Biopac_1.data.fs;
            
            % The section of the tobii data used for syncing (2 mins):
            tobiiSignalSection = 1:(2*60*syncFs);
            
            % Synthesize the marker signal from Tobii events:
            tobiiMarkSynthS = addEventSections(obj.(f).dataObj ...
                ,{'Marker','SyncPortOutHigh','SyncPortOutLow'});
            tobiiMarkSynth_t = (tobiiMarkSynthS.hit)';
            tobiiMarkSynth_t = tobiiMarkSynth_t(:)./1000;
            tobiiMarkSynth_y = repmat([1;0],length(tobiiMarkSynthS.hit),1);
            tobiiUpsampled_t = 0:(1/syncFs)...
                :(tobiiMarkSynth_t(end));
            tobiiMarkSynth = markerVolt.*...
                interp1(tobiiMarkSynth_t...
                ,tobiiMarkSynth_y...
                ,tobiiUpsampled_t...
                ,'previous');
            tobiiMarkSynth(isnan(tobiiMarkSynth)) = 0;
            
            % The recorded marker channel (biopac timeframe):
            tobiiMarkRec = obj.Biopac_1.data.channels...
                {obj.(f).biopac1SyncChannel};
            
            % Get delay:
            [C,Lags] = xcorr(tobiiMarkRec...
                ,tobiiMarkSynth(tobiiSignalSection));
            [~,delayIndx] = max(C);
            delayInSamples = Lags(delayIndx);
            
            % Check fit:
            xcorrScore = corrcoef(...
                tobiiMarkRec(delayInSamples+tobiiSignalSection)...
                ,tobiiMarkSynth(tobiiSignalSection));
            assert(all(all(xcorrScore>fitThreshold))...
                ,'The Tobii Marker Signals do not match!');
            
            % Set output:
            delay.seconds      = delayInSamples/syncFs;
            delay.samples      = delayInSamples;
            
            if false
                hFig = figure(); %#ok<UNRCH>
                title(['Synced! Delay = ' num2str(delay.seconds)...
                    's, xcorr = ' num2str(xcorrScore(2)) '.'])
                plot(tobiiUpsampled_t+delay.seconds...
                    ,tobiiMarkSynth); hold on
                plot(tobiiMarkSynth_t+delay.seconds...
                    ,tobiiMarkSynth_y.*markerVolt,'x');
                plot(timeVector(syncFs,length(tobiiMarkRec))...
                    ,tobiiMarkRec,'--'); hold on
                legend({'Signal from Tobii Marker events'...
                    'Tobii Marker Events'...
                    'Signal recorded by Biopac'})
                uiwait(hFig);
            end
            
            
            %  figure()
            %  plot(tobiiMarkRec); hold on
            %  plot(((1:length(tobiiMarkSynth))+delayInSamples)...
            %     ,tobiiMarkSynth)
            %  legend({'Acq Tobii markers' 'Tobii Event markers'});
            %  uiwait(gcf);
            
            end

        end
        
        
        %==================================================================
        function [ data, physioDataInfo ] = makeSyncedDataStruct(obj)
            
            if isempty(obj.globalTime)||isempty(obj.globalBounds)
                error('Process obj first!');
            end
            
            % Process Tobii 1:
            data.eyeTracking = returnStruct(obj.Tobii_1.dataObj...
                ,obj.Tobii_1.delay.seconds-obj.globalBounds(1));
                %,obj.globalBounds-obj.Tobii_1.delay.seconds);
            
                % Process Tobii 2:
            if ~isempty(obj.Tobii_2.filename)
                if isempty(obj.Tobii_2.dataObj)
                    error('Load Data First')
                end
                data.eyeTracking(2) = returnStruct(obj.Tobii_2.dataObj...
                    ,obj.Tobii_2.delay.seconds-obj.globalBounds(1));
                   % ,obj.globalBounds-obj.Tobii_2.delay.seconds);
            end

            % Process Biopac 1:
            fs             = obj.Biopac_1.data.fs;
            Biopac_1_t     = obj.globalTime;
            Biopac_1_valid = Biopac_1_t...
                >=obj.globalBounds(1)...
                &Biopac_1_t<obj.globalBounds(2);
            if obj.globalBounds(1)<0 ...
                    ||obj.globalBounds(2)>(Biopac_1_t(end)+(1/fs))
                error('Indexes are not in bounds.');
            end

            signals.channelUnits = obj.Biopac_1.data.unit;
            signals.channelNames = strcat(obj.Biopac_1.data.channelNames...
                ,{' ('},obj.Biopac_1.filename,{')'});
            signals.fs = fs;
            signals.channelDescription = {''};
            signals.SyncDesc ...
                = {sprintf(['Biopac 1 sectioned from %.3f' ...
                ' to %.3f s.'],obj.globalBounds(1),obj.globalBounds(2))};
            signals.channels = cellfun(@(c) c(Biopac_1_valid)...
                ,obj.Biopac_1.data.channels,'UniformOutput',false);
            data.signals = signals;
            if length(data.signals.channels{1})...
                    ~=sum(Biopac_1_valid)
                error('Error sectioning biopacs');
            end
            
            % Process Biopac 2:
            if ~isempty(obj.Biopac_2.filename)
                if ~isfield(obj.Biopac_2,'data')...
                        ||isempty(obj.Biopac_2.data)
                    error('Load Data First')
                end
                Biopac_2_t  = tGetFromDataStructField(obj.Biopac_2.data);
                localBounds = obj.globalBounds-obj.Biopac_2.delay.seconds;
                if localBounds(1)<0 ...
                        ||localBounds(2)>(Biopac_2_t(end)+(1/fs))
                    error('Indexes are not in bounds.');
                end

                
                % Generate the valid vector for biopac 2 by shofting the
                % valid vector of biopac 1 by the delay, in samples.
                Biopac_2_valid      = false(size(Biopac_2_t));
                shiftedValidIndeces = [find(Biopac_1_valid,1) ...
                    find(Biopac_1_valid,1,'last')]...
                    -obj.Biopac_2.delay.samples;
                shiftedValidIndeces(2) = min(shiftedValidIndeces(2)...
                    ,length(Biopac_2_valid));
                Biopac_2_valid(shiftedValidIndeces(1)...
                    :shiftedValidIndeces(2)) = true;
                biopac2Signals =  cellfun(@(c) c(Biopac_2_valid)...
                    ,obj.Biopac_2.data.channels,'UniformOutput',false);
                if length(biopac2Signals{1})...
                        ~= length(data.signals.channels{1})...
                        ||sum(Biopac_1_valid)...
                        ~=sum(Biopac_2_valid)...
                        ||length(biopac2Signals{1})~=sum(Biopac_2_valid)
                    error('Error sectioning biopacs');
                end
                signals.channelUnits ...
                    =  [signals.channelUnits obj.Biopac_2.data.unit];
                signals.channels = [signals.channels biopac2Signals];
                signals.channelNames = ...
                    [signals.channelNames ...
                    strcat(obj.Biopac_2.data.channelNames...
                    ,{' ('},obj.Biopac_2.filename,{')'})];
                signals.SyncDesc = {[signals.SyncDesc{1} ...
                    sprintf([' Biopac 2 sectioned from %.3f' ...
                    ' to %.3f s.'],shiftedValidIndeces(1)/1000 ...
                    ,shiftedValidIndeces(2)/1000 )]};
                data.signals = signals;
                
            end
            
            % Metadata:
            physioDataInfo.sourceFilename  = listToString({...
                obj.Biopac_1.filename obj.Biopac_2.filename ...
                obj.Tobii_1.filename obj.Tobii_2.filename});
            physioDataInfo.extracionUser    = getenv('USERNAME');
            physioDataInfo.extracionDate    = datestr(now);
            
            
        end
        
    end
end
