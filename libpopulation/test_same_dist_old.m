function [pDiff bNonEqualVar mc_comparison, mc_means] = test_same_dist(x, grp)
% test if the distribution from each group is same or not
% 2017 HRK
bV = ~isnan(x) & ~isnan(grp);
x = x(bV);
grp = grp(bV);
gnumel = grpstats(x, grp, 'numel');
[grpid gname] = grp2idx(grp);
bNonEqualVar = false;
mc_comparison = []; mc_means = [];

% if there are only two groups, compare median (Wilcoxon rank sum test)
if length(gname) == 2 && length(gnumel) == 2
    % test of equal variance for two samples
    % shit. not very rigorous. inactivate it for now.
%     [tmp,tmp1, bNonEqualVar] = SquaredRanksTest(x(grpid==1),x(grpid==2), 0.05, 0);
    bNonEqualVar = false;
    % if equal variance assumption is met, use M.W. U-test to test median
    % is same or not between the two distribution.
    if ~bNonEqualVar
        if nnum(x(grpid==1)) ==0 || nnum(x(grpid==2)) ==0 
            pDiff = NaN;
        else
            pDiff = ranksum(x(grpid==1),x(grpid==2)); 
        end
    else % otherwise use K.S test to examine if there same from the same distribution or not.
        [tmp pDiff] = kstest2(x(grpid == 1), x(grpid == 2));
    end
    
    % not accurate. just do it for now. modify it to use pDiff for 2 group
    % case.
    % try anova1 and multiple comparison
    [pANOVA1, ANOVATAB, ANOVA_STATS] = anova1(x, grp,'off');
    [mc_comparison, mc_means, mc_h, mc_gnames] = multcompare(ANOVA_STATS,'display','off');

elseif length(gname) > 2 && length(gnumel) > 1 && ( numel(x) > numel(unique(grp)) ) % if there is at least two groups
    % if there are more than two groups, run ANOVA
%     pDiff = anova1(x,grpid,'off');
    % Kruskal–Wallis one-way analysis of variance
    pDiff = kruskalwallis(x,grpid,'off');  
    
    % try anova1 and multiple comparison
%     [pANOVA1, ANOVATAB, ANOVA_STATS] = anova1(x, grp,'off');
%     [mc_comparison, mc_means, mc_h, mc_gnames] = multcompare(ANOVA_STATS,'display','off');

    % double check that the order of gname is same
    bSame = true;
    
    % try anova1 and multiple comparison
    [pANOVA1, ANOVATAB, ANOVA_STATS] = anova1(x, grp,'off');
    [mc_comparison, mc_means, mc_h, mc_gnames] = multcompare(ANOVA_STATS,'display','off');

    assert(numel(gname) == numel(mc_gnames));
    for iG = 1:numel(gname)
        if ~strcmp(gname{iG}, mc_gnames{iG}),  bSame = false; end
    end
    assert(bSame);
else
    pDiff = NaN;
end


