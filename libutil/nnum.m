function y=nnum(x)
% number of numbers (non-NaNs)
y=nnz(~isnan(x));