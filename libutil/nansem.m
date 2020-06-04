function r = nansem(x, dim)
% calculate standard error or mean
% 2016 HRK
if is_arg('dim')
    r = nanstd(x,[],dim) ./ sqrt(sum(~isnan(x),dim)); 
else
    r = nanstd(x) ./ sqrt(sum(~isnan(x)));
end