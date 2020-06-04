function reduce_axis_tick(hA)
% 5/28/2018 HRK

if numel(hA) > 1
    for iA = 1:numel(hA)
        reduce_axis_tick(hA(iA));
    end
    return;
end

% reduce # of x tick labels if there are too many
lT = get(hA, 'xtick'); lX = get(hA,'xticklabel');
if length(lX) == length(lT) && length(lT) >= 7
    lX = lX(1:2:end,:); lT = lT(1:2:end);
end
set(hA, 'xtick', lT, 'xticklabel',lX);

% reduce # of y tick labels
lT = get(hA, 'ytick'); lX = get(hA,'yticklabel');
if length(lX) == length(lT) && length(lT) >= 5
    lX = lX(1:2:end,:); lT = lT(1:2:end);
end
set(hA, 'ytick', lT, 'yticklabel',lX);