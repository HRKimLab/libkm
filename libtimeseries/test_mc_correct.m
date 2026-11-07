% TEST_MC_CORRECT test multiple comparison correction method
%  tested three MATLAB packages (bonf_holm.zip, fdr_bh.zip,
%  MultipleTestingToolbox.zip)
%  MultipleTestingToolbox seems to contain several other methods and be 
%  most comprehensive, but fdr_bh just seems to be enough. Let's use this
%  in the export folder.
%
% 2024 HRK

% generate a set of original P values. 
p_orig = [rand(1,40) * 0.03 rand(1,40) * 0.1]
% p_orig = [rand(1,80) * 0.03]; % rand(1,80) * 0.2]

% set FDR (for FDR method) and alpha (for Bonferroni method)
FDR = 0.05;
alpha = 0.05;

% obtain adjusted P values using different functions (for
% comparison/verification)
% some functions are now in Z:\km_lab\km_export_deprecated\.
% add paths if you want to test this again.
[p_adj_Bonferroni, h] = bonf_holm(p_orig, alpha)

[h, crit_p, adj_ci_cvrg, p_adj_Benjamini]=fdr_bh(p_orig, FDR , 'pdep', 'yes')

[p_adj_Benjamini2, c_alpha, h, extra] = fdr_BH(p_orig, FDR , true)

[p_adj_BY, c_alpha, h, extra] = fdr_BY(p_orig, FDR, 'ind', true)

[p_adj_HB2, c_alpha, h, extra] = fwer_holmbonf(p_orig, alpha, true)

[p_adj_B, c_alpha, h, extra] = fwer_bonf(p_orig, alpha, true)

% plot comparison results
setfig(2,1);
gna;
plot_barpair([p_orig' p_adj_B p_adj_Bonferroni' p_adj_HB2' p_adj_Benjamini' p_adj_Benjamini2' p_adj_BY'], [], 0.05)
gna;
plotsqscatter(p_orig', p_adj_BY');
draw_refs(NaN, .05, .05);
xlabel('P value, original'); ylabel('P value, FDR corr.');
