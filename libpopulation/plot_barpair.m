function [pPair pRef] = plot_barpair(x, is_sig, y_ref, varargin)
% plot bar plot with paired elements connected with lines
% 10/28/2017 HRK

yl = [];
show_individual = 1;
use_star = 0;
show_mc = 1;

process_varargin(varargin);

if ~is_arg('c'), c = [.5 .5 .5];    end;
if ~is_arg('y_ref'), y_ref = []; end;
if ~is_arg('is_sig'), is_sig = true(size(x)); end;

nCond = size(x, 2);
[v grp] = cols2grp(x, 1:nCond);
[is_sig grp] = cols2grp(is_sig, 1:nCond);

[grp_means grp_sem pRef pDiff mc_sig] = plot_bargrp(v, grp, 'is_sig', is_sig, 'y_ref', y_ref, 'yl', yl, ...
    'show_individual', show_individual, 'use_star', use_star, 'marker_color', c, 'show_mc', 0);

% compute correlation across groups (often group is an ordered variable)
[rG pG] = corr(grp, v, 'type','Spearman', 'rows','pairwise');

nR = nnz(any(~isnan(x),2));
atitle(sprintf('nR=%d,rG=%.2f,pG=%s', nR, rG, p2s(pG)), 1);


% draw lines to connect corresponding data points
if show_individual
    for iR = 1:size(x, 1)
        hSL = line(1:size(x, 2), x(iR,:),'color', c);
        
        % alpha for line only works for the new graphic engine
        % http://undocumentedmatlab.com/blog/plot-line-transparency-and-color-gradient
        if ~isnumeric(hSL) 
            hSL.Color = [.5 .5 .5 .25];
        end
    end
end

% do paired test
pPair = NaN(nCond, nCond);
for iR = 1:nCond
    for iC = iR+1:nCond
        if all(isnan(x(:,iR)) | isnan(x(:,iC))), continue; end
        pPair(iR, iC) = signrank(x(:,iR), x(:,iC));
    end
end
if nCond == 2
    atitle(sprintf('pPairD=%s', p2s(pPair(1,2))));
end

if ~show_mc
    return;
end

% draw multiple comparison based on pairwise test
mc_sig2 = [];
i_row = 1;
for iR = 1:numel(unique(grp))
    for iC= (iR+1):(numel(unique(grp)))
        mc_sig2(i_row, 1) = iR; mc_sig2(i_row, 2) = iC; 
        mc_sig2(i_row, 3) = pPair(iR, iC) < 0.05;
        i_row = i_row + 1;
    end
end
% make sure that column index arrangement is same as the original mc_sig
if ~isempty(mc_sig)
    assert(all(all(mc_sig2(:, [1 2]) == mc_sig(:, [1 2]))), 'mc_sig size is different. maybe there are NaN rows?');
end

disp_multiple_comparison_results(mc_sig2, get(gca,'ylim'));