function ylimnan(ax, x, mode)
% mode: 'none', 'union', 'intersect'
if ~ishandle(ax) % shift arguments
    if nargin == 1, x = ax; ax = gca; end
    if nargin == 2, mode = x; x = ax; ax = gca; end
end
assert(size(x,2) == 2);
if ~is_arg('mode'), mode = 'none'; end;

if numel(ax) > 1
    for iA = 1:numel(ax)
        ylimnan(ax(iA), x, mode);
    end
    return;
end
yl = get(ax, 'ylim');
if ~isnan(x(1))
    switch(mode)
        case 'none', yl(1) = x(1); 
        case 'union', yl(1) = min([x(1) yl(1)]);
        case 'intersect', yl(1) = max([x(1) yl(1)]);
    end
end

if ~isnan(x(2))
    switch(mode)
        case 'none', yl(2) = x(2); 
        case 'union', yl(2) = max([x(2) yl(2)]);
        case 'intersect', yl(2) = min([x(2) yl(2)]);
    end
end

set(ax, 'ylim', yl);