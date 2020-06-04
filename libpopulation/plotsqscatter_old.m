function [r,p,N,sl,itc,fitdata,pSR] = plotsqscatter_old(x,y,grp,xl, yl)
% libpopulation started from this old version of plotsqscatter. 
% now plotsqscatter() that calls plot_scatter replaced old version, but
% just leave it.
% regdata: [x y basic_#(N;r;p) fit_params(sl;itc)
% substitute x if given as column idx
% 2010? HRK
if length(x) == 1
    x_label = evalin('base', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('base', ['aPD(:,' num2str(x) ');']);
elseif ~isempty(inputname(1))
    x_label = inputname(1);
end
% substitute y if given as column idx
if length(y) == 1
    y_label = evalin('base', ['pcd_colname{' num2str(y) '}']); 
    y = evalin('base', ['aPD(:,' num2str(y) ');']);
elseif ~isempty(inputname(2))
    y_label = inputname(2);
end

% substitute grp if given as column idx
if ~is_arg('grp')
    grp = zeros(size(x)); 
elseif length(grp) == 1
    grp = evalin('base', ['aPD(:,' num2str(grp) ');']);
end

% set x limits
if ~is_arg('xl') && ~is_arg('yl')
    ranges=[setlim(x(:)) setlim(y(:))];
    xl = [min(ranges) max(ranges)]; 
    yl=xl;
elseif ~is_arg('yl')
    yl = xl;
end

% computer correlation
[r p N] = corrN(x,y,'type','Spearman','rows','pairwise');
% see if group variable have two columns (usually, subject x conditions)
grp_names=grpstats(ones([size(grp,1) 1]), grp, 'gname');
nGrpDiv = size(grp_names, 2);
nGrp = numel(grp_names);
if nGrpDiv == 2 % when grp division is 2, assume first is subject marked by shape
    gcolor = []; gshape = [];
    
    grp_shapes = '.v*xo';
    % shape is the index of the first column
    gshape = grp_shapes(grp2idx(grp_names(:,1)));
    
    if max(grp2idx(grp_names(:,2))) <= 7
        grp_colors='rgbmcyk';
        gcolor = grp_colors(grp2idx(grp_names(:,2)));
    else
        grp_colors = hsv(max(grp2idx(grp_names(:,2))));
        gcolor = grp_colors(grp2idx(grp_names(:,2)), :);
    end
    % color is the index of the second column
    
elseif nGrp == 1  % when totla grp is one, just do black
    gcolor='k'; gshape=[];
else
    gcolor=[]; gshape=[];
end
% plot scatter
hS = gscatter(x,y,grp,gcolor,gshape);
if ~is_arg('yl')
    yl=xl;
    % make axes square
    squarize(xl);
else
    xlim(xl); ylim(yl); draw_refs; 
    % occationally draw_refs distroy unequal axis. just do it again.
    xlim(xl); ylim(yl); 
end
% type 2 regression
bV = all(~isnan([x(:) y(:)]),2);
if nnz(bV) == 0
    title('N=0'); r = NaN; p= NaN; N= NaN; sl= NaN; itc= NaN; fitdata= NaN; return;
end
% can do regression only if more than one values on each axis
if length(unique(x(bV))) > 1 && length(unique(y(bV))) > 1
    [sl, itc] = regress_perp(x(bV),y(bV));
else
    sl=NaN; itc=NaN;
end
% plot regression line
yfit = xl * sl + itc;
hFit = line(xl,yfit,'color','k','linestyle',':');
set(hFit, 'tag', 'fit');
% do paired signed rank test
pSR = signrank(x,y);
% check outliers (data not shown)
nOL = nnz( x < xl(1) | x > xl(2) | y < yl(1) | y > yl(2) );

% show numbers
if nOL == 0
    title(sprintf('N=%d, r= %.2f (p=%s), x<>y (p=%s)', N, r, p2s(p), p2s(pSR)));
else
    title(sprintf('N=%d (OL=%d), r= %.2f (p=%s), x<>y (p=%s)', N-nOL, nOL, r, p2s(p), p2s(pSR)));
end
% if the correlation is positive, move legend to left top
if r > 0 && p < .1 && nGrp > 1
    legend(hS, 'location','northwest'); legend boxoff
elseif r < 0 && p < .1 && nGrp > 1
    legend(hS, 'location','northeast'); legend boxoff
elseif nGrp > 1     % no guess about location
    legend boxoff;
elseif nGrp == 1
    legend off;
end

if exist('x_label','var'), xlabel(regexprep(x_label,'_',' ')); end;
if exist('y_label','var'), ylabel(regexprep(y_label,'_',' ')); end;

% set regression line data
fitdata = GenRegLineData(sl, itc,xl,yl); nC = size(fitdata,2);
fitdata(:, nC+1:nC+2) = NaN(size(fitdata,1), 2);
% N r p
fitdata(1:3,nC+1) = [N;r;p];
% slope intercept
fitdata(1:2, nC+2) = [sl; itc];

return;