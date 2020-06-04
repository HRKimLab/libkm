function [data] = grp2cols(x, grp)
% convert column vector x and group variable grp, and return the matrix of
% [obs * # of groups]
% I don't like the name. need to change later.
% opposite: cols2grp
assert(size(x,2) == 1, 'x should be column vector');

x=x(:); [grpid gname] = grp2idx(grp);
nTot = length(x);
% plot histogram with significance based on edges
bV = ~isnan(x) & ~isnan(grpid);
x = x(bV);
grp = grp(bV);
grpid = grpid(bV);
nV = length(x);
% fill data
data = NaN(length(x), length(gname));
for iG=1:length(gname)
    bG = grpid == iG;
    data(1:nnz(bG),iG)= x(bG);
end
data(all(isnan(data),2),:) = [];

fprintf(1, '%d - %d (NaNs) = [', nTot, nTot-nV);
fprintf(1, '%d ', sum(~isnan(data))); 
fprintf(1, ']\n');;