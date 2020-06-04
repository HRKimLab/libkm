function b = setequal(x, y)
% test if two cell arrays have the same text elements
% 5/25/2018 HRK
b = false;

if numel(x) == numel(y) && isempty(setdiff(x, y)) && isempty(setdiff(y, x))
    b = true;
    return;
end