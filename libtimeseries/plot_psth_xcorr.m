function plot_psth_xcorr(psths, varargin)

grp = [];
grp_lim = 20;
individual_psth = 0;

process_varargin(varargin);

[cmap nColor grp_idx gname gnumel] = grp2coloridx(grp, grp_lim);

assert(numel(grp_idx) == nfields(psths), 'group # should match # of psths');
% compute border if grp_idx is sorted 
if all(sort(grp_idx, 'ascend') == grp_idx) || ...
        all(sort(grp_idx, 'descend') == grp_idx) 
    grp_border = find(abs(diff(grp_idx)) > 0);
end

p = setpanel(2,1, 'XCorr psths');
p.marginleft = 30; p.marginright = 20;

ax_image = p.gna;
plot_mpsths(psths, 'check_ginfo', 0, 'plot_type','image', 'avg_grp', grp, 'psth_sort_format', 'no_sort');

cF = fieldnames(psths);
set(ax_image,'yticklabelmode','manual','ytick', 1:numel(cF), 'yticklabel', cF);
set(draw_refs(0, NaN, grp_border + 0.5), 'linestyle',':');

ax_pop = p.gna;
plot_mpsths(psths, 'check_ginfo', 0, 'individual_psths', individual_psth, 'avg_grp', grp, ...
    'psth_sort_format', 'no_sort', 'legend_gnum', 1, 'auto_filter_x', 0);
% cF = fieldnames(psths);
% set(ax_pop,'yticklabelmode','manual','ytick', 1:numel(cF), 'yticklabel', cF);

linkaxes_ext([ax_image ax_pop], 'x');

% ax_xcorr = p.gna;
figure;
ax_xcorr = gca;
c_means = structfun(@(x) {x.mean}, psths);
% make big array X with time becoming rows
cc_VTA = cat(1, c_means{:})';
% compute correlation
[rF pF] = corr(cc_VTA,'rows','pairwise');
% plot results
imagesc(rF)
set( draw_refs(0, grp_border + 0.5, grp_border + 0.5) , 'linestyle', ':');
axis square
axis ij
xlim([0.5 size(rF,2)+0.5]); ylim([0.5 size(rF,1)+0.5]);
colorbar;
stitle('Xcorr, comparing %d entities', size(rF, 1));