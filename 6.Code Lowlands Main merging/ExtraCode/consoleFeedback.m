function newLine = consoleFeedback(varargin)
% consoleFeedback helps print feedback out on the console.
%
%     [newLine = ] consoleFeedback([varargin]), where varargin are level
%     end string pairs.
%
%     If newLine output argument is requested, then a function handle is
%     return with which the L2 line can be updated:
%
%      newLine(str) replaces the last <dynamic string> with the new 'str'.
%      Call newLine('done'[,varargin]) when done to show the ET, and
%      optionally call the consoleFeedback method or print results.
%      
%     The following format can be generated:
%
% =========================================================================
%   > Level 1 string.
% -------------------------------------------------------------------------
%
%      Level 2 string.....................: Done! (ET = 4.03 s).
%      # Level 3 (level 2 results):
%         - Level 4 string (results spec).
%
%      Level 2 string.....................: <Dynamic string> ...
%
% >>
%
%
% - Elio Sjak-Shie, March 2017.

%% Parameters:

% Define indents:
indents.L1  = '  > ';
indents.L2  = '    ';
indents.L3  = '     ¤ ';
indents.L4  = '        - ';

% Define horizontal lines:
maxWidth      = 73;
HL1           = repmat('=',1,maxWidth);
HL2           = repmat('-',1,maxWidth);

% Shape and style params:
padd          = 42;
doneFormat    = 'Done! (ET = %.2f s).\n';
endOfLineDots = sprintf(' ...\n');


%% Process Macros:

% Check inputs:
if mod(nargin,2)~=0
    error('Incorrect number of inputs!')
end

if nargout ==0
    parsePairs(varargin);
    return
    
end


%% Dynamic Line Writing Stuff:

% Check inputs:
if nargin~=2||~strcmp(varargin{1},'L2')
    error('Dynamic level 2 can only be called with 2 input args.');
end
curStrIN  = varargin{2};

% Store local persistent vars:
localTic      = tic;
lastLine      = '';

% Padd name:
curStrIN = [indents.L2 curStrIN];
if nargin>1&&length(curStrIN)<padd
    str = [curStrIN  repmat('.',1,padd-length(curStrIN)) ':'];
else
    str = [curStrIN ':'];
end

% Print name:
fprintf('%s %s',str,endOfLineDots);

% Return handle
newLine = @printNextLine;

%--------------------------------------------------------------------------
    function [strOut, colIndx] = parseString(level,strIN)
        % Insert indentation and wrap string.
        
        % Check color modifier:
        if level(end)=='R'
            colIndx = 2;
            level(end) = [];
        else
            colIndx = 1;
        end
        
        % Add indents:
        if (length(strIN)+length(indents.(level)))>maxWidth
            realMaxWidth = maxWidth - length(indents.(level));
            indentWhitespace = sprintf('\n%s'...
                ,repmat(' ',1,length(indents.(level))));
            exp = sprintf('(.{%d}|.{1,%d}(?:$))'...
                , realMaxWidth, realMaxWidth);
            strLines        = regexp(strIN, exp, 'tokens');
            strLines(1)     = strcat({indents.(level)},strLines{1});
            strLines(2:end) = strcat({indentWhitespace},[strLines{2:end}]);
            strOut =  sprintf('%s\n',[strLines{:}]);
        else
            strOut = sprintf('%s\n',[indents.(level) strIN]);
        end
    end


%--------------------------------------------------------------------------
    function printNextLine(curLine,varargin)
        % Prints a new line over an old one.
        
        % Clear previous line:
        fprintf(repmat('\b',1,length(lastLine)...
            +length(endOfLineDots)));
        
        if strcmpi(curLine,'done')
            fprintf(1,doneFormat,toc(localTic));
            parsePairs(varargin);
        else
            % Print new line:
            fprintf('%s%s',curLine,endOfLineDots);
            lastLine = curLine;
        end
    end


%--------------------------------------------------------------------------
    function parsePairs(argInCell)
        for arginIndex = 1:2:length(argInCell)
            
            % Get input current arg pairs, and force string(s) into
            % cell(s):
            level = argInCell{arginIndex};
            curStrIN  = argInCell{arginIndex+1};
            if ~iscell(curStrIN)
                curStrIN = {curStrIN};
            end
            if ~iscell(level)
                level = {level};
            end
            if length(level)~=length(curStrIN)
                level = repmat(level(1),length(curStrIN),1);
            end
            
            % Loop through input strings:
            for curCellIndx = 1:length(curStrIN)
                    [strOut,colInd] = parseString(...
                        level{curCellIndx},curStrIN{curCellIndx});
                
                % Check special conditions:
                if strcmp(level{curCellIndx},'L1')
                    if isempty(curStrIN{curCellIndx})
                        strOut = sprintf('%s\n',HL2);
                    else
                        strOut = sprintf('%s\n%s\n%s\n',HL1...
                            ,strOut(1:end-1),HL2);
                    end
                end
                fprintf(colInd,'%s',strOut);
            end
        end
        fprintf('\n');
    end
end