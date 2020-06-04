function [grp_means grp_sem pRef pDiff mc_sig gR gP] = plot_bargrp(y, grp, varargin)
% plot_barplot 
% plot bar graph with rows of (value, group). Perform statstics (compare
% with global mean, multiple comparisons).
% previous args: is_sig, y_ref, yl, show_individual
% 2017 HRK

is_sig = [];
y_ref = [];
yl = [];
show_individual = 1;
individual_size = 20;
r_with_grp = 0;
use_star = 0;
bar_color = [];
marker_color = [];
% estimator = @nanmean;
% eb = @nansem;
estimator = [];
show_mc = 1; % show multiple comparison results

process_varargin(varargin);

gR = NaN; gP = NaN; mc_sig = [];

if ~is_arg('yl'), yl = []; end;
if ~is_arg('is_sig'), is_sig = true(size(y)); end
if ~is_arg('y_ref'), y_ref = NaN; end;
if ~is_arg('show_individual'), show_individual = true; end;
if ~is_arg('bar_color'), bar_color = [.73 .73 .73]; end;
if ~is_arg('marker_color'), marker_color = darker(bar_color, 4); end;

assert(strcmp(class(is_sig), 'logical'), 'is_sig should be logical');
% substitute x if given as column idx
if length(y) == 1
    y_label = evalin('caller', ['pcd_colname{' num2str(y) '}']); 
    y = evalin('caller', ['aPD(:,' num2str(y) ');']);
elseif ~isempty(inputname(1))
    y_label = inputname(1);
end

% in case y is matrix, just consider columns separately
if size(y,1) > 1 && size(y,2) > 1
    nCond = size(y, 2);
    [y grp] = cols2grp(y, 1:nCond);
    [is_sig grp] = cols2grp(is_sig, 1:nCond);
end

% substitute grp if given as column idx
if ~is_arg('grp')
    grp = zeros(size(y)); 
elseif length(grp) == 1
    grp = evalin('caller', ['aPD(:,' num2str(grp) ');']);
end

% see if group variable have two columns (usually, subject x conditions)
grp_names = grpstats(ones([size(grp,1) 1]), grp, 'gname');
[grp_means grp_sem gnumel] = grpstats(y, grp, {'mean', 'sem','numel'});
if ~isempty(estimator)
    grp_means = grpstats(y, grp, estimator);
end
nGrpDiv = size(grp_names, 2);
nGrp = numel(grp_names);
if nGrpDiv == 2 % when grp division is 2, assume first is subject marked by shape
    gcolor = []; gshape = [];
    grp_colors='rgbmcyk';
    grp_shapes = '.v*xo';

    % shape is the index of the first column
    gshape = grp_shapes(grp2idx(grp_names(:,1)));
    % color is the index of the second column
    gcolor = grp_colors(grp2idx(grp_names(:,2)));
elseif nGrp == 1  % when totla grp is one, just do black
    gcolor='k'; gshape=[];
else
    gcolor=[]; gshape=[];
end

pRef = NaN(length(grp_names), 1);
pDiff = NaN;

% plot scatter
if size(grp,2) == 1
    [x tmp] = grp2idx(grp);
elseif isnumeric(grp)
    % for some reason, grp2idx doesn't work when grp has more than one
    % columns (actually, manual says it doesn't work for all grp
    % functions.. but it works for grpstats. 
    x=[];
    numeric_grp_name = cellfun(@str2num, grp_names);
    [tmp x] = ismember(grp, numeric_grp_name,'rows');
else, error('cannot parse grp. need to implement cell array');
end

if all(isnan(grp_means))
    return;
end


hB = bar(grp_means);
hold on;

set(hB,'EdgeColor','none');
set(hB,'barwidth', 0.5);
% works in matlab before graphics change (2014b)
if matlab_ver() < 8.4
    pH = arrayfun(@(x) allchild(x), hB);
else
    pH = hB;
end
% set(pH,'FaceAlpha',0.4);
set(pH,'facecolor', bar_color, 'facealpha', 1)

xl = setlim(x);

% show individual data points
if show_individual
    % data points with significance
    hS1 = scatter(x(is_sig), y(is_sig), individual_size, marker_color, 'o', 'filled');
    hold on;
    % data points without significance
    hS2 = scatter(x(~is_sig), y(~is_sig), individual_size, marker_color, 'o');
    hS = [hS1; hS2];
    if isfield(get(hS), 'MarkerFaceAlpha') % new graphic engine
        set(hS, 'MarkerFaceAlpha',0.25, 'MarkerEdgeAlpha', 0.25)
    end
else
    hS = [];
end

% draw errorbar
hE = errorbar(1:size(grp_names,1), grp_means, grp_sem,'linestyle','none');
% ch = get(hB,'child'); set(ch,'facea',.5);
set(hE, 'linewidth', 1.5,'color','k')

if isempty(yl)
    yl = ylim;
else
    set(gca, 'ylim', yl);
end

% check outliers (data not shown)
nOL = nnz( y < yl(1) | y > yl(2) );

% test same dist 
[pDiff bNonEqualVar mc_comparison] = test_same_dist(y, grp2idx(grp));

% show multiple comparison results
if ~isempty(mc_comparison)
    % mc_sig has three columns. [group 1, group 2, diff_is_significant(0/1)]
    mc_sig = mc_comparison(:, [1 2]);
    mc_sig(:,3) = mc_comparison(:, 3) .* mc_comparison(:, 5) > 0;
    
    if show_mc
        disp_multiple_comparison_results(mc_sig, yl);    
    end
else
    mc_sig = [];
end

% compare median with y_ref and show stats for each group
if ~isnan(y_ref)
   ux = nonnan_unique(x);
   for iX = 1:length(ux)
       bV = x == ux(iX);
       if nnum(y(bV)) == 0
           pRef(iX) = NaN;
       else
           pRef(iX) = signrank( y(bV) - y_ref );
       end
       if use_star % use star mark
            if pRef(iX) < 0.01
%                 x_off = 1/range(xlim)/2;
                x_off = 0.12;
                hStar = plot(ux(iX)+[-x_off x_off], ones(1,2)* (yl(1) + diff(yl)* 0.93), 'h');
                set(hStar,'tag','star', 'markerfacecolor',bar_color, 'color', bar_color, 'markersize', 5);
            elseif pRef(iX) < 0.05
                hStar = plot(ux(iX), yl(1) + diff(yl)* 0.93, 'h');
                set(hStar,'tag','star', 'markerfacecolor',bar_color, 'color', bar_color, 'markersize', 5 );
            end
       else % use text
            hT = text(ux(iX), yl(1) + diff(yl)* 0.93, sprintf('%s\nn=%d', p2s(pRef(iX)), nnum(y(bV))));
            set(hT, 'fontsize', 7, 'tag', 'pval','HorizontalAlignment','center');
       end
   end
   
   set(draw_refs(0, NaN, y_ref), 'linestyle', '--');
end

hold off;

% show numbers
if nOL == 0
    stitle('N=%d, pD=%s', sum(gnumel), p2s(pDiff));
else
    stitle('N=%d (OL=%d)(pD=%.2f)', nnum(y)-nOL, nOL, pDiff);
end

% compute r
if r_with_grp
    [gR gP] = corr(y, grp, 'type','Spearman', 'rows', 'pair');
    atitle(sprintf('gR=%.2f, gP=%s', gR, p2s(gP)));
    b = regress(y, [ones(size(grp)) x]);
    xl_reg = xlim();
    hReg = line( xl_reg, [ones(size(xl))' xl_reg'] * b );
	set(hReg,'color','k','linestyle', '--', 'tag','reg');
end


if exist('y_label','var'), ylabel(regexprep(y_label,'_',' ')); end;
set(gca, 'xticklabel',  grp_names);

dx = unique(diff(nonnan_unique(x)));
if numel(dx) > 1
    xl = minmax(x); xl(1) = xl(1) - dx/2; xl(2) = xl(2) + dx/2;
    set(gca, 'xlim', xl);
end

if strcmp(class(grp),'cell')
    cXL = regexprep(get(gca,'xticklabel'), '_', ' ');
    set(gca,'XTickLabel', cXL, 'XTickLabelRotation', 320);
end
return;