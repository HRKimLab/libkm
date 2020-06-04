function shrink_plots(ax, h, v);

if nargin == 2;
    v = h;
    h = ax;
    ax = findobj(gcf, 'type','axes');; 
end

for iA = 1:length(ax)
    pos = get(ax(iA), 'position');
    pos(1) = (pos(1)-0.5) * h + 0.5;
    pos(2) = (pos(2)-0.5) * v + 0.5;
    pos(3) = pos(3) * h;
    pos(4) = pos(4) * v;
    set(ax(iA), 'position', pos);
end