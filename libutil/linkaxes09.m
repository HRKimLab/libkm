function linkaxes09(ax, option);
% linkaxes sometimes choose smaller axis, which is odd.
% just take largest axis range

xl = [min(min(cell2mat(get(ax,'xlim')))) max(max(cell2mat(get(ax,'xlim'))))];
yl = [min(min(cell2mat(get(ax,'ylim')))) max(max(cell2mat(get(ax,'ylim'))))];

if any('x' == option)
    set(ax,'xlim', xl);
end
if any('y' == option)
   set(ax,'ylim', yl);
end

% then call linkaxes
linkaxes(ax, option);