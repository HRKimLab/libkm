function [p] = compare_cols(varargin)
% wrapping function for corr, return with valid (non-NaN) elements
% see also grp2cols, withingrpfunc
% HRK Dec 2012

% find valid, non-NaN elements
x=varargin{1};
if nargin == 1 || ~isnumeric(varargin{2})
    y = x;
else
    y = varargin{2};
end

nObs = size(x,1);

% some test need indivisual NaN filtering for each column
for i=1:size(x,2)
    for j=1:size(y,2)
        %bV = all(~isnan([x(:,i) y(:,j)]),2);
        bV = ~isnan(x(:,i));
        data = [x(bV,i) ones(size(x(bV,i)));];
        
        bV = ~isnan(y(:,j));
        data = [data; y(bV,j) 2*ones(size(y(bV,j)))];
        p(i,j) = Levenetest(data);
    end
end

return;
% some test need common NaN filtering for both columns toegether
for i=1:size(x,2)
    for j=1:size(y,2)
        bV = all(~isnan([x(:,i) y(:,j)]),2);
        %x(bV,i), y(bV,j)
        %p(i,j) = Levenetest(data);
    end
end