function linkprop09(ax, prop);
% linkaxes sometimes choose smaller axis, which is odd.
% just take largest axis range

xl = [min(min(cell2mat(get(ax, prop)))) max(max(cell2mat(get(ax, prop))))];

set(ax, prop, xl);

% then call linkaxes
linkprop(ax, prop);