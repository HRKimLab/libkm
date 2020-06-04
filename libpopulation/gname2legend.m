function [hP cG] = plot_mxmygrp(x,y,grp, sline)
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

cG=grpstats(y(:,1)',grp,'gname');
% [gidx,gnames,glevels] = grp2idx(grp)
%uG=grpstats(grp,grp,'mean');
uG=cellfun(@str2num,cG);
% this works when grp has more than one column
[a grp_idx] = ismember(grp, uG, 'rows');
cmap = jet(length(uG));
cla; hold on;
hP=[];
for iG=1:length(uG)
    iG
    tmp = plot(x(grp_idx==iG,:)', y(grp_idx==iG,:)', sline ,'color',cmap(iG,:));
    hP(iG) = tmp(1);
end
hold off;
cL = gname2legend(cG)
legend(hP, cL, cG,'uniformoutput',false));