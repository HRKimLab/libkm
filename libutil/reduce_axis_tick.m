function reduce_axis_tick(hA)
% reduce the number of axis ticks for presentation of publication
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
    if ismember(0, lT(1:2:end))
        lX = lX(1:2:end,:); lT = lT(1:2:end);
    elseif ismember(0, lT(2:2:end))
        lX = lX(2:2:end,:); lT = lT(2:2:end);
    else % neither has 0
        lX = lX(1:2:end,:); lT = lT(1:2:end);
    end
end
% change it only when label was not manually modified
if strcmp(get(hA, 'xticklabelmode'), 'auto')
    set(hA, 'xtick', lT, 'xticklabel',lX);
end

% reduce # of y tick labels
lT = get(hA, 'ytick'); lX = get(hA,'yticklabel');
if length(lX) == length(lT) && length(lT) >= 5
    if ismember(0, lT(1:2:end))
        lX = lX(1:2:end,:); lT = lT(1:2:end);
    elseif ismember(0, lT(2:2:end))
        lX = lX(2:2:end,:); lT = lT(2:2:end);
    else
        lX = lX(1:2:end,:); lT = lT(1:2:end);
    end
end
% change it only when label was not manually modified
if strcmp(get(hA, 'yticklabelmode'), 'auto')
    set(hA, 'ytick', lT, 'yticklabel',lX);
end