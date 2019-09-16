function strOut = listToString(listIn)
% Converts cellstring list into a string.
%
%   strOut = listToString(listIn)
%
%   e.g.: listToString({'One' 'Two' 'Tres'}) = '"One", "Two" and "Tres"'
%
%--------------------------------------------------------------------------
%   Part of the PhysioData Toolbox.
%    Elio Sjak-Shie, Faculty of Social Sciences,
%     Leiden University, 2016.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Changelog:
%
%   Oct-2016 -- Elio:
%        > Wrote first version.
%
%--------------------------------------------------------------------------


% What quotes to use:
quotes = '"';

% Check inputs:
assert(iscell(listIn))
listIn(cellfun(@isempty,listIn)) = [];
if isempty(listIn)
    strOut = 'none';
    return;
end
assert(min(size(listIn))==1)
if size(listIn,1)~=1
    listIn = listIn';
end

% Reformat list:
if length(listIn)>1
    listIn(2,:)     = listIn(1,:);
    listIn([1 3],:) = {quotes};
    listIn(4,:)     = {', '};
    listIn          = listIn(1:end-1);
    listIn(end-3)   = {' and '};
    strOut          = horzcat(listIn{:});
else
    strOut          = [quotes listIn{1} quotes];
end

end