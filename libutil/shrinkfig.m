function shrinkfig(fid)

ax = findobj(gcf, 'type','axes');
for iA = 1:length(ax)
    p = get(ax(iA), 'position');
    % get point coordinates
    p2 = p; 
    p2([3 4]) = p([1 2]) + p([3 4]);
    % shrink by 90% toward center of the current figure
    p2 = 0.9 * (p2 - 0.5) + 0.5;
    p2([3 4]) = p2([3 4]) - p2([1 2]);
    set(ax(iA), 'position', p2);
end