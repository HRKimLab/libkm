function hL_all = disp_multiple_comparison_results(mc_sig, yl)
% display multiple comparison results
% 2019 HRK
% set horizontal bar positions to mark significance between pairs
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