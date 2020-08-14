function [v mids num_psth] = TC2array(TC, fname, filter_func, mid_list)
% combine structure field of cell array to 2D array
% 10/18/2017 HRK
if ~is_arg('filter_func');
    filter_func = @(x) x;
end
mids = [];
% tmp = cellfun(@(x) filter_func( x.(fname) ), TC,'un',false);
tmp = cellfun(@(x) filter_func(get_fval( x, fname )), TC,'un',false);
v = cat(1, tmp{:});
% count # of psths combined for each cell
num_psth =cellfun(@(x) size(x,1), tmp);

if ~is_arg('mid_list')
    return;
end

assert(length(TC) == length(mid_list));
nNums = TC2array(TC, fname, @(x) size(x, 1));
for iN = 1:length(nNums)
    if nNums(iN) == 0, continue; end
    mids = [mids; ones(nNums(iN), 1) * mid_list(iN)];
end

function y = get_fval(x, fname)
if isempty(x)
    y = [];
else
   y = x.(fname); 
end