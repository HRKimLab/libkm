function [b, a, bint, aint, r, p] = plotsqscatter_hist(x,y, grp, varargin)

xl = [];        % xlim, ylim for scatter plot and histogram
histbin = [];   % bin to make edges for hitogram
ref = [];
xsig = [];      % it uses plot_hitsig for x if xsig is given
ysig = [];      % it uses plot_hitsig for y if ysig is given

process_varargin(varargin);

b=[], a=[], bint=[], aint=[], r=[], p=[];

if ~is_arg('histbin')
    hist_edges = linspace(min(xl), max(xl), 10);
else
    hist_edges = min(xl):histbin:max(xl);
end

if ~is_arg('xsig'), assert(size(x, 1) == size(xsig, 1)); end
if ~is_arg('ysig'), assert(size(y, 1) == size(ysig, 1)); end

if length(x) == 1
    x_label = evalin('caller', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('caller', ['aPD(:,' num2str(x) ');']);
elseif ~isempty(inputname(1))
    x_label = inputname(1);
else
    x_label = [];
end
% substitute y if given as column idx
if length(y) == 1
    y_label = evalin('caller', ['pcd_colname{' num2str(y) '}']); 
    y = evalin('caller', ['aPD(:,' num2str(y) ');']);
elseif ~isempty(inputname(2))
    y_label = inputname(2);
else
    y_label = [];
end

setfig(2,2);
axDesc = gna; set(axDesc,'tag','desc');
ax = gna; 
if ~isempty(xsig)
    plot_histsig(x,xsig, hist_edges, ref);
else
    plot_histgrp(x,grp, hist_edges, ref);
end
xlabel(x_label);
set(ax,'tag','hist');
ax = gna; 
if ~isempty(ysig)
    plot_histsig(y,ysig, hist_edges, ref);
else
    plot_histgrp(y,grp, hist_edges, ref);
end
xlabel(y_label);
set(ax,'tag','hist');
ax = gna; 
plotsqscatter(x,y,grp,'xl', xl);
xlabel(x_label); ylabel(y_label);
set(ax,'tag','scatter');
bV = ~isnan(x) & ~isnan(y);
[b, a, bint, aint, r, p] = regress_perp(x(bV),y(bV));
% get the size of scatter
pos_scatter = get(findobj(gcf,'tag','scatter'), 'position');
% set x same as scatter
% ax_hists = findobj(gcf,'tag','hist')
% pos_hist = get(ax_hists(1), 'position');
% set( ax_hists(1), 'position', [pos_hist(1:2) pos_scatter(3) pos_hist(4)]);
% pos_hist = get(ax_hists(2), 'position');
% set( ax_hists(2), 'position', [pos_hist(1:2) pos_scatter(3) pos_hist(4)]);
axes(axDesc)
xpos = 0; ypos = 1; 
if ~isempty(x_label)
    sLine = sprintf('X: %s', regexprep(x_label,'_','-'));
    text(xpos, ypos, sLine); ypos = ypos - 0.1;
end
if ~isempty(y_label)
    sLine = sprintf('Y: %s', regexprep(y_label,'_','-'));
    text(xpos, ypos, sLine); ypos = ypos - 0.1;
end
sLine = sprintf('y = %f x + %f', b, a);
text(xpos, ypos, sLine); ypos = ypos - 0.1;
sLine = sprintf('CI slope: [%f %f]', bint(1), bint(2));
text(xpos, ypos, sLine); ypos = ypos - 0.1;
sLine = sprintf('CI itc: [%f %f]', aint(1), aint(2));
text(xpos, ypos, sLine); ypos = ypos - 0.1;
axis off;