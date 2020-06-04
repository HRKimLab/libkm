function ytick(ax, x)
if nargin == 1, x = ax; ax = gca; end;

if numel(ax) > 1
    for iA = 1:numel(ax)
       ytick(ax(iA), x);
    end
    return;
end

% ignore the side that has NaN
xl = get(ax, 'ylim');
if ~isnan(x(1)), xl(1) = x(1); end;
if ~isnan(x(end)), xl(2) = x(end); end;

xt = nonnans(x);
set(ax, 'ytick', xt, 'yticklabelmode','auto', 'ylim', xl)

% re-adjust pval texts
hP = findobj(ax, 'tag','pval');
for iT = 1:length(hP)
    pos = get(hP(iT), 'Position');
    set(hP(iT), 'Position', [pos(1) xl(2) 0]);
end
