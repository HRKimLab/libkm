function [pDiff bNonEqualVar mc_comparison, mc_means, pPair] = test_same_dist(x, grp, varargin)
% TEST_same_dist tests two hypotheses for one-way layout
% 1) if x is from the same distribution (pDiff)
% 2) multiple comparisons between pairs of groups (mc_comparison)
% perform either parametric or non-parametric test assuming that 
% it is not paired data. 
% paired test is done separately in plot_barpair().
%
% revamped 2020; 2017 separated from plot_histgrp HRK

% from PMC153434: As a rule, nonparametric methods, particularly when used in small samples, 
% have rather less power (i.e. less chance of detecting a true effect where one exists) than 
% their parametric equivalents, and this is particularly true of the sign test (see Siegel and Castellan [3] 
% for further details).

% nonpar: non-parametric; par: parametric
% par_cond: parameteric if conditions are met (not implemented yet)
test_type = 'nonpar';  % 'nonpar', 'par', 'par_cond'
sig_crit = 0.05;

process_varargin(varargin);

% get basic # and group infos
bV = ~isnan(x) & ~isnan(grp);
x = x(bV);
grp = grp(bV);
gnumel = grpstats(x, grp, 'numel');
[grpid gname] = grp2idx(grp);

% initialize results
bNonEqualVar = false;
mc_comparison = []; mc_means = [];
pDiff = NaN;
nCond = max(grpid);
pPair = NaN(nCond, nCond);

% check if we have proper numbers of data for each group
if length(gname) == 2 && length(gnumel) == 2 % for two groups
    if nnum(x(grpid==1)) ==0 || nnum(x(grpid==2)) ==0
        warning('test_same_diff: 1/2 group is empty. skip test');
        return;
    end
elseif numel(gname) > 2 && numel(gnumel) > 1 && ... % for more than two groups
        numel(x) > numel(unique(grp))
    % this is OK condition
else
    warning('test_same_diff: group # is not appropriate for test. skip');
    return;
end

% just run 1-way ANOVA here. for nonparametric test, it will be overwirtten.
% it's necessary as I check if the multiple comparisons for nonparametric test
% have the same size as that of ANOVA for compatibility.
[pDiff ANOVATAB, ANOVA_STATS] = anova1(x, grp,'off');
% compute multiple comparisons (will be overwritten for nonparametric test)
% note that multcompare compensate for the overestimate of P value
[mc_comparison, mc_means, mc_h, mc_gnames] = multcompare(ANOVA_STATS, 'display', 'off');
% make mc_comparison to be [idx1, idx2, is_sig]
mc_comparison(:,3) = mc_comparison(:, 3) .* mc_comparison(:, 5) > 0;
mc_comparison(:, 4:end) = [];

% sanity checks for multiple comparisons
% make sure multcompare outputs consistent group #
assert(numel(gname) == numel(mc_gnames));
% double check that the order of gname is same
bSame = true;
for iG = 1:numel(gname)
    if ~strcmp(gname{iG}, mc_gnames{iG}),  bSame = false; end
end
assert(bSame, 'orders of group name do not match');

% perform equal variance test. It seems that it also works reasonably for 
% nonparametric data. but I may use different tests for nonpar/par
bNonEqualVar = false;
pEqualVar = vartestn(x, grp, 'TestType', 'LeveneAbsolute','display','off');
if pEqualVar < sig_crit
    warning('equal variance condition does not meet (P=%s)', p2s(pEqualVar));
end

switch (test_type)
    case 'par' % parametric test
        % for two groups, one-way ANOVA is same as t-test.
        % check normality for each group
        for iG = 1:max(grpid)
            [h_kstest(iG) p_kstest(iG)] = kstest(zscore( x(grpid == iG)) );
        end
        if any(p_kstest < sig_crit)
            gids = grpid(p_kstest < sig_crit);
            warning('test_same_diff: grpid %s does not meet normality assumption', ...
                sprintf('%d ', gids(:) ) );
        end
        
    case 'nonpar'
        % number of groups is two
        if length(gname) == 2 && length(gnumel) == 2
            if ~bNonEqualVar
                % Wilcoxon rank-sum test
                pDiff = ranksum(x(grpid==1),x(grpid==2));
            else
                % use K.S test to examine if there same from the same distribution or not.
                [tmp pDiff] = kstest2(x(grpid == 1), x(grpid == 2));
            end
        elseif length(gname) > 2 && length(gnumel) > 1 && ( numel(x) > numel(unique(grp)) )
            % Kruskal–Wallis one-way analysis of variance
            pDiff = kruskalwallis(x, grpid, 'off');
        end
        
        % do nonparametric test for multiple comparisons (rank sum test)
        % NOTE: this is slight different from parametric results
        % comparison as I do not compensate for multiple comparisons.
        for iR = 1:nCond
            for iC = iR+1:nCond
                if all(isnan(x(grpid == iR))) || all(isnan(x(grpid == iC)))
                    continue; 
                end
                % Wilcoxon rank-sum test
                pPair(iR, iC) = ranksum(x(grpid == iR), x(grpid == iC));
            end
        end
        
        % make [idx1 idx2 is_sig]
        mc_sig2 = [];
        i_row = 1;
        for iR = 1:numel(unique(grp))
            for iC= (iR+1):(numel(unique(grp)))
                mc_sig2(i_row, 1) = iR; mc_sig2(i_row, 2) = iC;
                mc_sig2(i_row, 3) = pPair(iR, iC) < sig_crit;
                i_row = i_row + 1;
            end
        end
        
        % sanity check that mc_sig2 has the same structure as mc_comparison
        assert(all( size(mc_comparison) == size(mc_sig2) ), 'mc_comparisons do not match');
        assert(all(all(mc_sig2(:,[1 2]) == mc_comparison(:, [1 2]))), ...
            'mc_comparison indices do not match');
        % oversrite mc_comparison with the nonparametric version
        mc_comparison = mc_sig2;     
        
    otherwise
        error('not implemented yet');
end

% sanity check for the size of output variables
assert(numel(pDiff) == 1);
assert(numel(bNonEqualVar)==1);
assert(size(mc_comparison, 2)==3);
assert(size(mc_means, 1) == max(grpid) && size(mc_means,2) == 2);