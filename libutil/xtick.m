function xtick(ax, x)
if nargin == 1, x = ax; ax = gca; end;

% ignore nonsense params
if numel(x) == 1, return; end;

if numel(ax) > 1
    for iA=1:numel(ax)
        xtick(ax(iA), x);
    end
   return
end
% ignore the side that has NaN
xl = get(ax, 'xlim');
if ~isnan(x(1)), xl(1) = x(1); end;
if ~isnan(x(end)), xl(2) = x(end); end;

xt = nonnans(x);
set(ax, 'xtick', xt, 'xticklabelmode','auto', 'xlim', xl)