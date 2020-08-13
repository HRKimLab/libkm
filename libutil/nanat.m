function y = nanat(x, idx)
% return element at the idx or NaN if size is smaller than idx
% 2020 HRK
assert(any(size(x) == 1), 'x should be either row or column vector'); 
if numel(x) < idx
    y = NaN;
else
    y = x(idx);
end