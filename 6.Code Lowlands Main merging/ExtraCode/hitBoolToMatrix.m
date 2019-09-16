function RoImatrix = hitBoolToMatrix(RoI,t_ms)
% Transforms hit booleans vector to a start stop matrix.
%
%    Note: all RoIs are ended at the last sample. RoI that start at the
%    last sample are therefore destroyed.
%
%

% Get the hits:
if ischar(RoI{1})
    curHits = strcmp(RoI,'1');
elseif isnumeric(RoI{1})
    curHits = logical(RoI);
else
    error('Unexpected data type in hits column.')
end

% always end the last RoI on the last sample:
curHits(end) = false;

% Generate the matrix:
starts    = diff([false;curHits])==1;
ends      = diff([false;curHits])==-1;
RoImatrix = [t_ms(starts) t_ms(ends)];
