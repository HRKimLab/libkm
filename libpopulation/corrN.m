function [r p N] = corrN(varargin)
% wrapping function for corr, return with valid (non-NaN) elements
% HRK Dec 2012

% find valid, non-NaN elements
x=varargin{1};
if nargin == 1 || ~isnumeric(varargin{2})
    y = x;
else
    y = varargin{2};
end
% get valid number of elements
for i=1:size(x,2)
    for j=1:size(y,2)
        N(i,j) = nnz(all(~isnan([x(:,i) y(:,j)]),2));
    end
end

% call corr function
[r p] = corr(varargin{:});


