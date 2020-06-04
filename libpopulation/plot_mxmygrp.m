function [hP u_grp] = plot_mxmygrp(x,y,grp, sline)
% plotm_xygrp(x,y,grp, sline)
% x: m * n 
% y: m * n 
% grp: 1 * m or m * 1

% assert(size(x,2)==size(y,2), 'size(x,2): %d should be same as size(y,2): %d', size(x,2), size(y,2));
% assert(size(y,1)==size(grp,1), 'size(y,1): %d should be same as size(grp,1): %d', size(y,1), size(grp,1));

if ~is_arg('grp')
    grp = ones(size(x,2), 1);
end

if ~is_arg('sline'), sline = '-'; end;

[grp_idx u_grp cL] = mgrp2idx(grp);
cmap = jet(length(u_grp));
cla; hold on;
hP=[];

for iG=1:length(unique(grp_idx))
    tmp = plot(x(grp_idx==iG,:)', y(grp_idx==iG,:)', sline ,'color',cmap(iG,:));
    if isempty(tmp)
        hP(iG) = NaN;
    else
        hP(iG) = tmp(1);
    end
end
hold off;
legend(hP, cL);