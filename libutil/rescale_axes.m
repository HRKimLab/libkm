function rescale_axes(ax, h, v);
% rescale axes 
% 2018 HRK 
if ishandle(ax) && strcmp(get(ax,'type'), 'axes')
else
    v = h;
    h = ax;
    ax = gca;
end

% ax = findobj(gcf, 'type','axes');
for iA = 1:length(ax)
    pos = get(ax(iA), 'position');
    pos(3) = pos(3) * h;
    pos(4) = pos(4) * v;
    set(ax(iA), 'position', pos);
end