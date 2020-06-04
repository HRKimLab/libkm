function [h_psth hT hL] = plot_psma(psth, errbar_type, cmap, varargin)
% plot peri-stimulus moving average
% 1/27/2017 HRK
mean = []; p2 = NaN; pBaseDiff = NaN; gname = [];
h_psth = [];
hT = [];
y_sigmark = [];
legend_gnum = 0;
set_lim = 1;
ax = [];  % this is not implemented yet. I need to implement this to speed up processing
smooth_win = [];     % for additional smoothing in plot_mpsth

if isempty(psth), return; end;

process_varargin(varargin);

struct2var(psth);
 
if ~is_arg(ax), ax = gca; end;

if isempty(gname), return; end;
nColor = size(mean, 1) ;
if ~is_arg('gnumel')
    gnumel = NaN(1, nColor);
end
if ~is_arg('cmap')
    cmap = get_cmap(nColor);
end
if size(cmap,1) < nColor
    warning('# of color < nColor. use get_cmap');
    cmap = get_cmap(nColor);
end

h_psth = NaN(nColor, 2);

if ~is_arg('idx_sorted_by_num') && nColor == 1
    idx_sorted_by_num = 1;
end

% plot mean+-stderr response
% plot from small # condition to large # condition to avoid large sem
% superimpose everything. Make sure to keep the order in h_psth same as 
% increasing order in grp since I use that to add legend.
hold on;

for iG = idx_sorted_by_num'
   % only plot non-NaN datapoints
  is_valid = ~isnan(mean(iG,:)) & ~isnan(sem(iG,:)); % & numel(iG,:) > 10;
  if nnz(is_valid) == 0, continue; end;

  h_psth(iG, :) = draw_errorbar( x(is_valid), mean(iG, is_valid), sem(iG, is_valid), cmap(iG,:), errbar_type);
end
hold off;

% set xlim, ylim
[xl yl] = get_plot_range(psth);
if set_lim
    set(gca, 'xlim', xl, 'ylim', yl);
end

% mark test difference between groups
yl = ylim;
if isempty(y_sigmark), y_sigmark = yl(1); end;

if any(~isnan(pDiff))
    hold on;
    y_cord = ones(1, nnz(pDiff<.05)) * y_sigmark;
    
    % mark bins in which resps are group means are significantly different
    hP = plot(x(pDiff<.05), y_cord,'s','color',[.5 .5 .5], 'markersize', 2.5, 'markerfacecolor', [.5 .5 .5] );
    set(hP, 'tag', 'sigmark');
    hold off;
end

% mark test difference between pre-event vs. post-event
if any(any(~isnan(pBaseDiff)))
    hold on;
    for iG = 1:nColor
        y_cord = ones(1, nnz(pBaseDiff(iG,:) <.05 )) * y_sigmark + iG * diff(yl) * 0.03;
        hP = plot(x(pBaseDiff(iG,:) < .05), y_cord,'s','color', cmap(iG,:), 'markersize', 2.5, 'markerfacecolor', cmap(iG,:) );
        set(hP, 'tag', 'sigmark');
    end
    hold off;
end

% text stats discription
if any(~isnan(p2))
    hold on;
    if nColor == 1
        hT = text(x(1), yl(2) * 0.9, sprintf('P_{time} = %s, P_{trial}=%s', p2s(p2(1)), p2s(p2(3)) ) );
    else
        hT = text(x(1), yl(2) * 0.9, sprintf('P_{time} = %s, P_{grp}=%s, P_{trial}=%s', p2s(p2(1)), p2s(p2(2)), p2s(p2(3)) ) );
    end
    set(hT, 'fontsize', 6, 'tag', 'pval');
    hold off;
end

% use group label from ginfo if possible
if isfield(psth, 'ginfo') && ~isempty(psth.ginfo)
    glabel = psth.ginfo.unq_grp_label;
    assert(length(glabel) >= length(gname), 'ginfo label and data does not match');
else
    glabel = arrayfun(@num2str, gname, 'un',false);
end

% plot legend
hL = [];
if nColor > 1
    cL = {};
    for iG =1:nColor
        if legend_gnum
%             cL{iG} = [num2str(glabel(iG)) '(n=' num2str(gnumel(iG)) ')'];
            cL{iG} = [glabel{iG} '(n=' num2str(gnumel(iG)) ')'];
        else
          cL{iG} = [glabel{iG}];
        end
           
    end
    bV = ~isnan(h_psth(:,2));
    hL = legend(h_psth(bV, 2), cL(bV), 'location', 'best');
    legend(gca, 'boxoff'); 
    if nColor > 1
        set(hL, 'fontsize', 7);
        color_legend(hL);
%         position_legend(hL);
    end;
    
end