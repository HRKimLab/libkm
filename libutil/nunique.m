function n = nunique(x)
% number of unique non-nans
% 2015 HRK
n = length(unique(nonnans(x)));