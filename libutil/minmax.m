function r = minmax(x)
% get min nad max, return NaN if x is empty
% 2017 HRK
r = [nanmin(x(:)) nanmax(x(:))];
