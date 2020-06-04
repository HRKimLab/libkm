function xlimnan(x)
assert(size(x,2) == 2);

yl = get(gca, 'xlim');
if ~isnan(x(1)), yl(1) = x(1); end;
if ~isnan(x(2)), yl(2) = x(2); end;

set(gca, 'xlim', yl);