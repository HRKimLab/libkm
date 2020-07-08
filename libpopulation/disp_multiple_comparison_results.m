function hL_all = disp_multiple_comparison_results(mc_sig, yl)
% display multiple comparison results
% 2019 HRK
% set horizontal bar positions to mark significance between pairs

% make sure that mc_sig is [idx1, idx2, is_sig] and not 
% the return variable from multcompare
assert(size(mc_sig, 2) == 3, 'the size of mc_sig should be n * 3');
assert(all( mc_sig(:,3) == 0 | mc_sig(:,3) == 1 ), 'mc_sig(:,3) should be either 0 or 1');

y_pos = linspace(yl(1)+range(yl) * 0.83, yl(1)+range(yl) * 0.92, size(mc_sig, 1) );
hL_all = [];
for iMC = 1:size(mc_sig,1)
    hL = line( mc_sig(iMC, 1:2), ones(1,2)*y_pos(iMC), 'marker', 'o', 'color','k','markersize', 4);
    set(hL, 'tag', 'mc');
    % if confidence interval does not include zero, mark it significant
    if mc_sig(iMC, 3)
        set(hL, 'markerfacecolor', 'k');
    else
    end
    hL_all = [hL_all; hL];
end