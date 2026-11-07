function [hP u_grp] = plot_mxmygrp_tr(x,y,grp, varargin)
% PLOT_MXMYGRP_TR plot matrix x, matrix y, color by group, tranposed args
%  plotm_xygrp_tr(x,y,grp, sline)
%  x: n * m 
%  y: n * m 
%  grp: 1 * m
%
% See also PLOT_MXMYGRP

sline = '-';
mcolor = [];
ssize = 10;
cmap = [];

process_varargin(varargin);

assert(size(x,1)==size(y,1), 'size(x,1): %d should be same as size(y,1): %d', size(x,1), size(y,1));
assert(size(x,2)==size(y,2), 'size(x,2): %d should be same as size(y,2): %d', size(x,2), size(y,2));
assert(size(y,2)==size(grp,2), 'size(y,2): %d should be same as size(grp,2): %d', size(y,2), size(grp,2));

if ~is_arg('grp')
    grp = ones(1, size(x,2) );
end

if ~is_arg('sline'), sline = '-'; end;
if is_arg('mcolor')
    assert(size(x, 1) == size(mcolor, 1), 'size(mx, 1) should be same as size(mcolor,1)');
end

% exclude NaNs in grp
bV = any(~isnan(grp), 1);

% mgrp2idx requres entities go in row
[grp_idx u_grp cL] = mgrp2idx( grp(bV)' );
if isempty(cmap)
    cmap = jet(length(u_grp));
else
    assert(size(cmap, 1) == length(u_grp), 'size(cmap, 1) should match with grp #');
end
cla; hold on;
hP=[];

for iG = 1:length(unique(grp_idx))
    tmp = plot(x(:, grp_idx==iG), y(:, grp_idx==iG), sline , 'color',cmap(iG,:));
    if isempty(tmp)
        hP(iG) = NaN;
    else
        hP(iG) = tmp(1);
    end
end

% if mcolor is given, color trajectory using scatter()
if is_arg('mcolor')
    scatter( downsample(x(:), 10), ...
        downsample(y(:), 10), ssize, downsample(mcolor(:), 10), 'filled')
end

hold off;
legend(hP, cL);