function s = num2str_short(x)
assert(isnumeric(x));
if isinteger(x)
    s = num2str(s);
else
    s = sprintf('%.1f', x);
end