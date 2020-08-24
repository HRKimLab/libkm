function [grp_means grp_sem pRef pDiff pPair] = plot_barpair(x, is_sig, y_ref, varargin)
% plot bar plot with paired elements connected with lines
% 10/28/2017 HRK
%
% from PMC153434: As a rule, nonparametric methods, particularly when used in small samples, 
% have rather less power (i.e. less chance of detecting a true effect where one exists) than 
% their parametric equivalents, and this is particularly true of the sign test (see Siegel and Castellan [3] 
% for further details).

yl = [];
show_individual = 1;
use_star = 0;
show_mc = 1;    % show multiple comparisons
bar_x = 1;      % bar start position. can be a vector (same size as size(x,2))
test_type = 'nonpar';  % 'nonpar', 'par', 'par_cond'

process_varargin(varargin);

if ~is_arg('c'), c = [.5 .5 .5];    end;
if ~is_arg('y_ref'), y_ref = []; end;
if ~is_arg('is_sig'), is_sig = true(size(x)); end;
if numel(bar_x) == 0 
    bar_x = 1:size(x, 2);
elseif (numel(bar_x) == 1 && size(x, 2) > 1)
    bar_x = bar_x:(bar_x+size(x, 2)-1);
end

nCond = size(x, 2);
[v grp] = cols2grp(x, 1:nCond);
[is_sig grp] = cols2grp(is_sig, 1:nCond);

[grp_means grp_sem pRef pDiff mc_sig] = plot_bargrp(v, grp, 'is_sig', is_sig, 'y_ref', y_ref, 'yl', yl, ...
    'show_individual', show_individual, 'use_star', use_star, 'marker_color', c, 'show_mc', 0, ...
    'bar_x', bar_x, 'test_type', test_type, 'individual_x_width', 0);

% compute correlation across groups (often group is an ordered variable)
[rG pG] = corr(grp, v, 'type','Spearman', 'rows','pairwise');

nR = nnz(any(~isnan(x),2));
atitle(sprintf('nR=%d,rG=%.2f,pG=%s', nR, rG, p2s(pG)), 1);

% draw lines to connect corresponding data points
if show_individual
    for iR = 1:size(x, 1)
        hSL = line(bar_x, x(iR,:),'color', c);
        
        % alpha for line only works for the new graphic engine
        % http://undocumentedmatlab.com/blog/plot-line-transparency-and-color-gradient
        if ~isnumeric(hSL) 
            hSL.Color = [.5 .5 .5 .25];
        end
    end
end

% get valid rows
bVX = ~isnan(x);
% valid rows
bVR = all(bVX, 2);
% check if there are rows that partially contain NaNs
if any(any(bVX(~bVR,:)))
    warning('some non-NaN values have paired NaNs. will be excluded in repeated measures ANOVA and Friedman''s test');
end

% NOTE: this is different from multcompare result, which compensate 
% for multiple comparisons. This should not be used for judging population 
% as a whole.
switch(test_type)
    case 'nonpar'
        % do Friedman's test.
        % The Friedman test is a non-parametric statistical test developed by Milton Friedman.[1][2][3] 
        % Similar to the parametric repeated measures ANOVA, it is used to detect differences in treatments 
        % across multiple test attempts.
        % NOTE: I noticed that Friedman's test sometimes gives higher
        % P-vale than Kruskal–Wallis test. 
        % NOTE 2: P value using signed rank test with group # two is not
        % same as Friedman's test. something seems to be different.
        
        if nCond > 1 && nnz(bVR) < 2
            pDiff_friedman = NaN;
        elseif nCond > 1
            pDiff_friedman = friedman(x(bVR,:), 1, 'off');
            
            if pDiff < pDiff_friedman && (pDiff_friedman > 0.01 && pDiff > 0.01)
            fprintf('plot_barpair: P value using Kruskal–Wallis test(%.3f) > Friedman''s test(%.3f)\n', ...
                pDiff, pDiff_friedman );
            
            end
        else
            pDiff_friedman = NaN;
        end
        
        % overwrite for now
        pDiff = pDiff_friedman;
        
        % do nonparametric paired test (signed rank test)
        pPair = NaN(nCond, nCond);
        for iR = 1:nCond
            for iC = iR+1:nCond
                if all(isnan(x(:,iR)) | isnan(x(:,iC))), continue; end
                pPair(iR, iC) = signrank(x(:,iR), x(:,iC));
            end
        end
    case 'par'
        % do repeated measures ANOVA instead of ANOVA
        if nCond > 1
            pDiff_ANOVA_RM = anova_rm(x(bVR,:), 'off');
        else
            pDiff_ANOVA_RM = NaN;
        end
        pDiff = pDiff_ANOVA_RM(1);
        % do parametric paired test
        pPair = NaN(nCond, nCond);
        for iR = 1:nCond
            for iC = iR+1:nCond
                if all(isnan(x(:,iR)) | isnan(x(:,iC))), continue; end
                [~, pPair(iR, iC)] = ttest(x(:,iR), x(:,iC));
            end
        end
    otherwise
        error('not implemented yet');
end

if nCond == 2
    atitle(sprintf('pPairD=%s,pRepD=%s', p2s(pPair(1,2)), p2s(pDiff)) );
else
    atitle(sprintf('pRepD=%s', p2s(pDiff)) );
end

if ~show_mc
    return;
end

% draw multiple comparison based on pairwise test
mc_sig2 = NaN(0, 3);
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

if all(bar_x == (1:size(x, 2)) )
    disp_multiple_comparison_results(mc_sig2, get(gca,'ylim'));
else
    warning('multiple compairson only supports the standard bar_x for now');
end