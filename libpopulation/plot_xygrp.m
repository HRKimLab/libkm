function [hP xye] = plot_xygrp(x,y, grp, errbar_type, varargin)
% plot_xygrp(x,y, errbar_type)
% compute std or sem of y based on x, and plot errorbars.
% errbar = 'sem' | 'std'

show_individual = 0;
individual_size = 20;

process_varargin(varargin);

if ~is_arg('errbar_type'), errbar_type = 'sem'; end;
if ~is_arg('grp'), grp = ones(size(x)); end;

% x and y should be column vectors
assert(size(x,2) == 1); assert(size(y,2) == 1); 

[grp cGrp] = grp2idx(grp);
bV = ~isnan(x) & ~isnan(y) & ~isnan(grp);
x(~bV) = NaN; x(~bV) = NaN; grp(~bV) = NaN;

orig_x = x;
orig_y = y;
% cGrp = grpstats(grp, grp, 'gname');

uGrp = nonnan_unique(grp);
nG = length(uGrp);
xye = NaN(nG, nG * 3);

if nG == 1
    cmap = [0 0 0];
else
    cmap = jet(nG);
end

prev_nextplot = get(gca,'nextplot'); % hold on;. wrong. just keep prev status

hold on;
hP=[];
for iG=1:nG
   x = orig_x(grp == uGrp(iG));
   y = orig_y(grp == uGrp(iG));
   
   cG = grpstats(y,x,'gname');
   unique_x = cellfun(@(x) str2num(x), cG);

   mG = grpstats(y,x,'mean');
   nGnum = grpstats(y,x,'numel');
   % stdG = grpstats(y,x,'std');
   % serrG = stdG ./ sqrt(nGnum);
   serrG = grpstats(y,x, errbar_type);

   marker_color = brighter(cmap(iG,:), 2);
   scatter(x, y, individual_size, marker_color, 'o', 'filled');
   hP(iG) = plot(unique_x, mG,'-o','color', cmap(iG,:));
   errorbar(unique_x, mG, serrG, 'color', cmap(iG,:));
   
   % save x, y, err
   nX = length(unique_x);
   xye(1:nX, iG * 3 - 2) = unique_x;
   xye(1:nX, iG * 3 - 1) = mG;
   xye(1:nX, iG * 3 ) = serrG;
end
hold off;
set(gca,'nextplot', prev_nextplot); % hold off;

nN = length(x);
% legend(hP, arrayfun(@(x) sprintf('%.2f',x), uGrp,'uniformoutput',false));
legend(hP, cellfun(@(x) sprintf('%s',x), cGrp,'uniformoutput',false));
title(sprintf('N=%d, nG=%d', nN, length(cG)));