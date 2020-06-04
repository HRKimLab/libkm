function plotm_scatter(x,y,grp)
% plotm_xygrp(x,y,grp, sline)
% plot'm' means that y is a matrix
% x: 1 * n preference of neurons
% y: m * n responses
% grp: m * 1 stimulus parameters

assert(size(x,2)==size(y,2), 'size(x,2): %d should be same as size(y,2): %d', size(x,2), size(y,2));
assert(size(y,1)==size(grp,1), 'size(y,1): %d should be same as size(grp,1): %d', size(y,1), size(grp,1));

if ~is_arg('grp')
    grp = ones(size(y,1),1);
end

x = repmat(x, [size(y,1) 1]);
grp = repmat(grp, [size(y,2) 1]);

plot_scatter(x(:),y(:),grp);

return;