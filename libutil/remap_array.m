function s2 = remap_array(s, x, y)

assert( all(size(x) == size(y)) );
s2 = s;
bRemapped = false(size(s));

for iX = 1:numel(x)
    bV = s == x(iX);
    s2(bV) = y(iX);
    bRemapped(bV) = true;
end

% remap NaNs
bNaN_s = isnan(s);
bNaN_x = isnan(x);
if any(bNaN_s)
    if any(bNaN_x) % convert NaN to y
        assert(nnz(bNaN_x) == 1);
        s2(bNaN_s) = y(bNaN_x);
        bRemapped(bNaN_s) = true;
    else % assign NaN
        s2(bNaN_s) = NaN;
        bRemapped(bNaN_s) = true;
    end
end

if ~all(bRemapped)
    warning('remap_array: Not all elements were remapped: %s', num2str( unique( s(~bRemapped) ) ));
end