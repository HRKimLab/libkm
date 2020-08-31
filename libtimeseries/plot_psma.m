function [h_psth hT hL h_event] = plot_psma(psth, varargin)
% plot peri-stimulus moving average
%  psth is a structure computed by compute_avggrp()
% 1/27/2017 HRK
% mean = []; p2 = NaN; pBaseDiff = NaN; gname = [];
eb_type = []; % erorbar type
cmap = []; 
h_psth = [];
h_event = [];
hT = [];
y_sigmark = [];
legend_gnum = 0;
set_lim = 1;    % 1: respect matlab's range. more generous 2: tight based on actual range
ax = [];  % this is not implemented yet. I need to implement this to speed up processing
smooth_win = [];     % for additional smoothing, for example, when called by plot_mpsth
mark_diff = 1;
show_legend = 1;
grp_xlim = [];        % set xlim for each group such that I don't see large noise (small n) endings
base_lim = [];       % for baseline subtraction
event_header = {};
tag_grp = 0;
marker_size = 2.5;
valid_x_crit = 0.5;        % criterion to determine how many trials should be at the time point to consider it valid. now I check this in compute_rate. this is for psths saved before that.
auto_filter_x = 1;       % for concatenated psths, it's good to include nans to disconnect each individual one.
color_event_by_grp = 0;    % color event based on group, not by event type
subsample_x = 1;           % subsample x for plotting. the data size becomes roughly inversly proportional to this ratio

if isempty(psth), return; end;
if ~isstruct(psth) || ~isfield(psth, 'mean')
    error('psth is not a valid structure from plot_timecourse');
end

process_varargin(varargin);

% struct2var(psth);

nColor = size(psth.mean, 1);
if ~is_arg('eb_type'), eb_type = 'patch'; end
if ~is_arg('cmap'), cmap = get_cmap(nColor); end
if ~isempty(base_lim), assert(size(base_lim,2) == 2, 'base_lim should be (1,2)'); end
if isempty(ax), ax = gca; end;
    
if isempty(psth.gname), return; end;

if ~isfield(psth, 'gnumel')
    gnumel = NaN(1, nColor);
else
    gnumel = psth.gnumel;
end

if size(cmap,1) < nColor
    warning('# of color < nColor. use get_cmap');
    cmap = get_cmap(nColor);
end

if ~isempty(grp_xlim)
    assert(size(grp_xlim,2) == 2, 'grp_xlim should have 2 columns (min, max)');
    assert(size(grp_xlim, 1) == nColor, '# of groups are different');
end

h_psth = NaN(nColor, 2);

% if ~is_arg('idx_sorted_by_num') && nColor == 1
%     idx_sorted_by_num = 1;
% end

% plot mean+-stderr response
% plot from small # condition to large # condition to avoid large sem
% superimpose everything. Make sure to keep the order in h_psth same as 
% increasing order in grp since I use that to add legend.
set(ax, 'NextPlot', 'add');

% additional smoothing for smoother curve (e.g., for plot_mpsth_xsession or plot_mpsth_xneuron)
% don't do it here. just do it in the individual function.
mean_rate = psth.mean;
% if ~isempty(smooth_win)
%     mean_rate = conv2(mean_rate, ones(1, smooth_win) / smooth_win, 'same');
% end

% baseline subtraction it of course, window should be non-nans
if ~isempty(base_lim) && all(~isnan(base_lim))
    base_rate = nanmean(mean_rate(:, base_lim(1) <= psth.x & psth.x < base_lim(2)), 2);
    mean_rate = bsxfun(@minus, mean_rate, base_rate);
end

for iG = psth.idx_sorted_by_num'
  if auto_filter_x
      % only plot non-NaN datapoints
       is_valid = ~isnan(mean_rate(iG,:))& ~isnan(psth.sem(iG,:)); 
       % to avoid larger error bars, show data point with # of trials > (total # of trials) / 3
        % now I examine this in compute_rate. this is for psth saved before that.
        is_valid  = is_valid & psth.numel(iG,:) > psth.n_grp(iG)*valid_x_crit; % numel(iG,:) > 10;
  else
      is_valid = true(size(psth.x));
  end
    
  % apply grp_xlim
  if ~isempty(grp_xlim)
      is_valid = is_valid & ( grp_xlim(iG,1) <= psth.x & psth.x < grp_xlim(iG,2) );
  end
  if nnz(is_valid) == 0, continue; end;

  % create subsampling mask
  resample_mask = false(size(is_valid));
  resample_mask(1:subsample_x:end) = true;
  
  % get subsamped mask
  is_valid = is_valid & resample_mask;
  
  h_psth(iG, :) = draw_errorbar( psth.x(is_valid), mean_rate(iG, is_valid), psth.sem(iG, is_valid), cmap(iG,:), eb_type, ax);
  
  if tag_grp
      set(h_psth(iG, :), 'tag', ['G' num2str(iG)]);
  end
end

set(ax, 'NextPlot', 'replace');

% set xlim, ylim
[xl yl] = get_plot_range(psth);
switch(set_lim)
    case 1
%     xl_orig = get(ax,'xlim');
%     xl(1) = nanmin([xl(1) xl_orig(1)]); xl(2) = nanmax([xl(2) xl_orig(2)]);
     set(ax, 'xlim', xl);
    
      yl_orig = get(ax, 'ylim');
      yl(1) = nanmin([yl(1) yl_orig(1)]); yl(2) = nanmax([yl(2) yl_orig(2)]);
      set(ax, 'ylim', yl);
    case 2
        set(ax, 'xlim', xl);
        set(ax, 'ylim', yl);
end

% mark test difference between groups
yl = ylim(ax);
if isempty(y_sigmark), y_sigmark = yl(1); end;

if mark_diff && any(~isnan(psth.pDiff))
    set(ax, 'NextPlot', 'add');
    
    if any(psth.pDiff<.05)
        % if any data point is significant, mark it by filled square
        y_cord = ones(1, nnz(psth.pDiff<.05)) * y_sigmark;
        % mark bins in which resps are group means are significantly different
        hP = plot(ax, psth.x(psth.pDiff<.05), y_cord,'s','color',[.5 .5 .5], 'markersize', marker_size, 'markerfacecolor', [.5 .5 .5] );
    else % if none is significant, mark it by open square
        y_cord = ones(1, nnz(psth.pDiff > .05)) * y_sigmark;
        % mark bins in which resps are group means are significantly different
        hP = plot(ax, psth.x(psth.pDiff > .05), y_cord,'s','color',[.5 .5 .5], 'markersize', marker_size, 'markerfacecolor', 'none' );
    end
    set(hP, 'tag', 'sigmark');
    set(ax, 'NextPlot', 'replace');
end

% mark test difference between pre-event vs. post-event
if mark_diff && any(any(~isnan(psth.pBaseDiff)))
    set(ax, 'NextPlot', 'add');
    for iG = 1:nColor
        y_cord = ones(1, nnz(psth.pBaseDiff(iG,:) <.05 )) * y_sigmark + iG * diff(yl) * 0.03;
        hP = plot(ax, psth.x(psth.pBaseDiff(iG,:) < .05), y_cord,'s','color', cmap(iG,:), 'markersize', marker_size, 'markerfacecolor', cmap(iG,:) );
        set(hP, 'tag', 'sigmark');
    end
    set(ax, 'NextPlot', 'replace');
end

% text stats discription
if mark_diff && any(~isnan(psth.p2))
    set(ax, 'NextPlot', 'add');
    if nColor == 1
        hT = text(psth.x(1), yl(2) * 0.9, sprintf('P_{time} = %s, P_{trial}=%s', p2s(psth.p2(1)), p2s(psth.p2(3)) ) ,'parent', ax);
    else
        hT = text(psth.x(1), yl(2) * 0.9, sprintf('P_{time} = %s, P_{grp}=%s, P_{trial}=%s', p2s(psth.p2(1)), p2s(psth.p2(2)), p2s(psth.p2(3)) ) ,'parent', ax);
    end
    set(hT, 'fontsize', 6, 'tag', 'pval');
    set(ax, 'NextPlot', 'replace');
end

% use group label from ginfo if possible
if isfield(psth, 'ginfo') && ~isempty(psth.ginfo) && isfield(psth.ginfo, 'unq_grp_label')
    glabel = psth.ginfo.unq_grp_label;
    assert(length(glabel) >= length(psth.gname), 'ginfo label and data does not match');
else
    glabel = arrayfun(@num2str, psth.gname, 'un',false);
end

% show event
% set marker for each event
% nMarker = size(events, 1);
% % keep this same as the ones in plot_events_on_raster()
% marker_list = {'rx','gx','mx','cx','yx','kx','r+','g+','m+','c+','y+','k+','rv','gv','mv','cv','yv','kv'};
% color_list = {'r','g','m','c','y','k','r','g','m','c','y','k','r','g','m','c','y','k'};
if ~isempty(event_header) && isfield(psth, 'event')
    if isstr(event_header)
        event_header = {event_header};
    end
    if strcmp(event_header{1}, 'all')
        events = psth.event;
    else
        assert(all(ismember(event_header, psth.event.Properties.VariableNames)), 'event header is not a valid one')
        events = psth.event(:, event_header);
    end
    nG = size(events, 1);
    if color_event_by_grp
        event_color_grp = cmap;
    else
        event_color_grp = [];
    end
    [h_event] = plot_events_on_psth(ax, table2array(events)*1000, zeros(nG,1), (1:nG)', ...
        events.Properties.VariableNames, 'color_grp',  event_color_grp);
end

% plot legend
hL = [];
if show_legend && nColor > 1
    cL = {};
    for iG = psth.idx_sorted_by_num'
        if legend_gnum
%             cL{iG} = [num2str(glabel(iG)) '(n=' num2str(gnumel(iG)) ')'];
            cL{iG} = [glabel{iG} '(n=' num2str(gnumel(iG)) ')'];
        else
          cL{iG} = [glabel{iG}];
        end
           
    end
    bV = ~isnan(h_psth(:,2));
    hL = legend(h_psth(bV, 2), cL(bV), 'location', 'best');
    legend(ax, 'boxoff'); 
    if nColor > 1
        set(hL, 'fontsize', 7);
        color_legend(hL);
%         position_legend(hL);
    end;
else
    hL = [];
end