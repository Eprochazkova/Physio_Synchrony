function t = tGetFromDataStructField(dataIn)
%tGetFromDataStructField Extracts the time vector from a datastruct.
%
%     t = tGetFromDataStructField(dataIn) extracts the time vector from a
%     datastruct, containing either a t vector, or an fs.
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

if isfield(dataIn,'t')
    t = dataIn.t;
elseif isfield(dataIn,'fs')
    if isfield(dataIn,'channels')
        t = timeVector(dataIn.fs,length(dataIn.channels{1}));
    elseif isfield(dataIn,'diameter')
        t = timeVector(dataIn.fs,size(dataIn.diameter,1));
    else
        error('Error generating time vector, unknow structure')
    end
else
    error('Error generating time vector, unknow structure')
end

end

