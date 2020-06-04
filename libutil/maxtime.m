function t = maxtime(x, varargin)
% get the second argument of max
if nargin == 1
    [~, t] = max(x);
else
    [~, t] = max(x, varargin{:});
end