function p = nansignrank(x)
% 2020 HRK
if all(isnan(x))
    p = NaN;
else
    p = signrank(x);
end