function [grpnames grpval] = num2bin(v,nbin)

if ~is_arg('nbin'), nbin = 10; end;

v = v(:)';
v = [v; nan(size(v))];

[n c] = hist(v, nbin)

[iGrp tmp] = find(n);

gname = arrayfun(@(x) sprintf('%.2f',x), c,'uniformoutput',false);

grpnames = gname(iGrp);
grpval = c(iGrp);