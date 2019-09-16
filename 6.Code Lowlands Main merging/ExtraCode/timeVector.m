function [t] = timeVector(fs,varargin)
%timeVector generate a uniform t vector [s].
%
%   [t] = timeVector(fs,L) generates a uniform time vector t of length L,
%   starting at 0, with sampling interval 1/fs.
%
%   [t] = timeVector(fs,tStart,tEnd) generates a uniform time vector t
%   starting at from time tStart to tEnd, with with sampling interval 1/fs.
%   The length is return in L.
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

% Check input:
narginchk(1,3);
assert(isscalar(fs)&isnumeric(fs),'fs must be a scalar number');

% Generate t:
if nargin==2
    
    % Parse input:
    L = varargin{1};
    
    % Generate t (BEWARE THE FLOATING POINT PRECISION):
    t = (0:(1/fs):((L/fs)-(1/fs)))';
    
else
    
    % Parse input:
    tStart = varargin{1};
    tEnd   = varargin{2};
    assert(tEnd>=tStart,'tEnd must be larger or equal to tStart');
    
    % Generate t:
    if tEnd==tStart
        t = tStart;
    else
        t = tStart:(1/fs):tEnd-(1/fs);
    end
    
end
end

