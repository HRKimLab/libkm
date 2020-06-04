function integerize_tick(ax, xy)
% change the tick to be integer
% 10/23/17 HRK
if ~is_arg('ax'), ax = gca; end;
if ~is_arg('xy')
    integerize_tick(ax, 'x');
    integerize_tick(ax, 'y');
    return;
end

if xy == 'x'
    xl = get(ax, 'xlim');
    if diff(xl) < 10
        xt = get(ax, 'xtick');
        xt = round(xt);
        set(ax, 'xtick', xt, 'xticklabel', xt);
        set(ax, 'xlim', xl);
    end
end

if xy == 'y'
    yl = get(ax, 'ylim');
    if diff(yl) < 10
        yt = get(ax, 'ytick');
        yt = round(yt);
        set(ax, 'ytick', yt, 'yticklabel', yt);
        set(ax, 'ylim', yl);
    end
end