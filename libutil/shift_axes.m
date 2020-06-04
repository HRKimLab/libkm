function shift_axes(h, v);

ax = findobj(gcf, 'type','axes');
for iA = 1:length(ax)
    pos = get(ax(iA), 'position');
    pos(1) = pos(1) + h;
    pos(2) = pos(2) + v;
    set(ax(iA), 'position', pos);
end