function [avg_psth psths h_avgpsth h_psth h_event] = plot_mpsths(cPSTH, varargin)
% superimpose cell array of multiple PSTHs in one axis and plot average of them
%  or draw image array with each row representing individual PSTHs.
% changed filename from plot_TC_psth to plot_multiple_psths
% See also asave_psth  
% 10/31/2017 HRK

% grouping and filtering psths
x = [];
n_grp = [];             % designate # of groups to combine
y_sigmark = [];
check_ginfo = 1;        % do hard check on ginfo to examine not only # of groups but the values of them
per_subject = [];
% plotting and other processing
x_base = -1;
pct_basediff = 0;       % show % of significant baseline difference
individual_psths = 0;   % show individual PSTHs
individual_events = [];    % show individual events. will follow individual_psths if empty
line_color = [];
smooth_win = [];        % re-smooth if necessary
h_psth = [];
ax = [];
errbar_type = 'patch';
show_legend = 1;
plot_type = 'line';     % 'line' or 'image;
grp_xlim = [];
avg_grp  = [];
base_lim = [];          % baseline subtraction. Subtraction is done for each group and psth independently.
event_header = {};        % event headers to show on the psth (e.g., {'VSTIM_ON_CD', 'RewOn'}
test_diff = 1;
adjust_x_anyway = 0;     % allow adjusting x eveen if x is not a subset of psth.x, by expending elements of psth
tag_grp = 0;             % tag individual groups for condition-by-condition presentation
mark_diff = 0;
sort_by_grp = 1;       % for color-coded image plot, re-order rows based on group
norm_method = 'none';
homogenize = 1;         % homogenize psth. you can skip it in certain situation (e.g., call it for neurons from the same session)
psth_sort_format = [];         % 'unitkey5', 'no_sort'
legend_gnum = 0;            % show # of groups in legend
auto_filter_x = 1;       % set 0 if want to disconnect individual psths in concatenated form
color_event_by_grp = 0;   % color event in PSTH by cmap for each group

% process options
process_varargin(varargin);

avg_psth = []; comb_means = []; h_avgpsth = []; h_psth = []; h_event = [];
if isempty(cPSTH) || (isstruct(cPSTH) && numel(fieldnames(cPSTH)) == 0)
    return; 
end
n_tot_psths = nfields(cPSTH);

% do not sort psths by default for plot type image unless specified
if isempty(psth_sort_format) && strcmp(plot_type, 'image')
        psth_sort_format = 'no_sort';
end

if isempty(individual_events)
    individual_events = individual_psths;
elseif individual_events && ~individual_psths 
    % just avoid the case the user think it's perfectly aligned.
    error('individual_psths should be on to see individual_events')
end

% homogenize psths by adjusting time range and pick idential group # 
% and group information (if check_grifo == 1)
if homogenize 
    [psths x n_grp] = homogenize_psths(cPSTH, 'x', x, 'n_grp', n_grp, ...
    'adjust_x_anyway', adjust_x_anyway, 'check_ginfo', check_ginfo, 'psth_sort_format', psth_sort_format);
else
    psths = cPSTH; 
    cF = fieldnames(psths);
    n_grp = nunique(psths.(cF{1}).grp);
    x = psths.(cF{1}).x;
end
n_homogenized_psths = nfields(psths);

% per-subject filtering. This assums that that psth field is unitkey5 format
if ~isempty(per_subject)
    [psths nSubject] = select_representative_psths(psths, 'per_subject', per_subject);
else
    nSubject = NaN;
end

[flist cPSTH] = sort_psth_structs(psths, psth_sort_format);
n_psth = numel(cPSTH);
b_valid_psths = true(n_psth, 1);

if isnan(nSubject)
    stitle('n=%d/nHo=%d/nTot=%d (nG=%d)', n_psth, n_homogenized_psths, n_tot_psths, n_grp);
else
    stitle('n=%d/nHo=%d/nTot=%d (nS=%d,nG=%d)', n_psth, n_homogenized_psths, n_tot_psths, nSubject, n_grp);
end

if n_psth == 0
    return;
end

% print name of psths used for plotting
print_psths_loading_info(psths);
%% filtering and homogenizing is done. 
% now plot individual psths, combine psths, and plot averaged psth
if isempty(line_color)
    line_color = get_cmap(n_grp);
elseif numel(line_color) < n_grp
    warning('# of color (%d) < # of groups (%d). use get_cmap', numel(line_color), n_grp);
    line_color = get_cmap(n_grp);
end

% overwrite comb_grp and line_color if avg_grp is given
if ~isempty(avg_grp)
    % if avg_grp is given, we are interested in per-psth difference so n_grp should be 1. 
    % also make sure the there is no sorting in psths
    assert(n_grp == 1, 'per-psth group should be 1 when arg_grp is given');
    assert(n_tot_psths == size(avg_grp, 1), '# of avg_grp should match # of input psths');
    assert(n_homogenized_psths == size(avg_grp, 1), '# of avg_grp should match # of homogenized psths');
    assert(strcmp(psth_sort_format, 'no_sort'), 'sort option should be no_sort with avg_grp');

    [avg_grp_cmap,~, avg_grp_idx] = grp2coloridx(avg_grp, 20);
end

% plot individual psths
for iR = 1:n_psth
    % plot individual PSTHs.
    if strcmp(plot_type, 'line') && individual_psths 
        % detemine whether to show individual events or not
        if individual_events
            tmp_header = event_header;
        else
            tmp_header = {};
        end
        
        tmp = plot_psma(cPSTH{iR}, 'eb_type','none', 'cmap', brighter(brighter(brighter(line_color))), 'mark_diff', mark_diff, ...
            'show_legend', 0, 'ax', ax, 'grp_xlim', grp_xlim, 'base_lim', base_lim, 'event_header', tmp_header, 'tag_grp', tag_grp, ...
            'auto_filter_x', auto_filter_x);
        h_psth = [h_psth; tmp];
        
        % if avg_grp is set, color the line according to the avg_grp
        if ~isempty(avg_grp)
            set(tmp, 'color', avg_grp_cmap(avg_grp_idx(iR),:));
        end
    end
end
    
% variables for combined psths
comb_means = NaN( n_psth * n_grp, size(x, 2) );
comb_pBaseDiff = NaN( n_psth * n_grp, size(x, 2) );
comb_grp = NaN( n_psth * n_grp, 1);

% combine multiple PSMAs (peri-stimulus moving average)
for iR = 1:n_psth
        row_idx = ((iR-1)*n_grp+1):((iR)*n_grp);
        tmp_mean = cPSTH{iR}.mean;
        comb_pBaseDiff(row_idx, :) = cPSTH{iR}.pBaseDiff;
        comb_grp(row_idx) = cPSTH{iR}.gname;
        
        % normalize mean
        switch(norm_method)
            case 'none'
                comb_means(row_idx, :) = tmp_mean;
            case 'max'
                % use 97% max
                comb_means(row_idx, :) = tmp_mean ./ prctile(tmp_mean(:), 97);
            case 'zscore'
                comb_means(row_idx, :) = (tmp_mean - nanmean(tmp_mean(:))) / nanstd(tmp_mean(:));
            case 'roc'
                comb_means(row_idx, :) = cPSTH{iR}.roc;
        end
end

if ~isempty(avg_grp)
    assert(size(comb_means, 1) == size(avg_grp, 1), '# of combined mean (%d) should match # of avg_grp (%d)', ...
        size(comb_means, 1), size(avg_grp, 1) );
    assert(all(size(comb_grp) == size(avg_grp)), 'size of comb_grp should match avg_grp');
    comb_grp = avg_grp;
    % here, update line_color since it will be used for plotting avg_grp
    line_color = avg_grp_cmap;
end

% re-smooth original PSMA if necessary
if is_arg('smooth_win')
    comb_means = conv2(comb_means, ones(1, smooth_win) / smooth_win,'same');
end

% baseline subtraction
if ~isempty(base_lim) && all(~isnan(base_lim))
    base_rate = nanmean(comb_means(:, base_lim(1) <= x(1,:) & x(1,:) < base_lim(2)), 2);
    comb_means = bsxfun(@minus, comb_means, base_rate);
end

% compute averaged psth from the combined PSMAs
avg_psth = compute_avggrp(x(1,:), comb_means, comb_grp, 'test_diff', test_diff, 'test_timediff', 0, 'test_bin', 10, 'x_base', x_base);

% assign ginfo
for iP = 1:n_psth
    if isfield(cPSTH{iP}, 'ginfo'), avg_psth.ginfo = cPSTH{iP}.ginfo; break; end;
end

% get event header for PSTHs
[avg_psth.event avg_psth.individual_event] = get_mpsths_events(cPSTH, 'event_header', event_header, 'b_valid_psths', b_valid_psths);

% plot averaged psth
switch(plot_type)
    case 'line' % plot averaged PSMA
        [h_avgpsth, hT, hL, h_event]  = plot_psma(avg_psth, 'eb_type', errbar_type, 'cmap', line_color, 'y_sigmark', y_sigmark, ...
            'mark_diff', mark_diff, 'ax', ax, 'show_legend', show_legend, ...
            'grp_xlim', grp_xlim, 'event_header', event_header, 'tag_grp', tag_grp, ...
            'legend_gnum', legend_gnum, 'auto_filter_x', auto_filter_x, 'color_event_by_grp', color_event_by_grp);
        set(nonnans(h_avgpsth), 'linewidth', 2); % make avg psth line thicker
        draw_refs(0, 0, NaN, ax);
        pct_bnd = prctile(comb_means(:), [1 99]);
        yl = [pct_bnd(1) - range(pct_bnd) * 0.1 pct_bnd(2) + range(pct_bnd) * 0.1];
        if nunique(yl) == 2, ylim(yl); end
%         set(h_avgpsth, 'linewidth', 2,'linestyle',':');
        
    case 'image' % draw image plot with rows for individual PSTHs
        [~,~,grp_idx] = grp2coloridx(avg_psth.grp);
        
        if sort_by_grp
            % sort trials based on group and trial #
            [~, idx_trials] = sortrows([grp_idx (1:size(avg_psth.rate_rsp, 1))']);
        else
            idx_trials = (1:size(avg_psth.rate_rsp, 1))';
        end

        plot_continuous_array(avg_psth.x, avg_psth.rate_rsp(idx_trials,:), grp_idx(idx_trials), 1, ax);

        % show events
        if ~isempty(event_header) && isfield(avg_psth, 'event')
            if isstr(event_header)
                event_header = {event_header};
            end
            if strcmp(event_header{1}, 'all')
                events = avg_psth.event;
            else
                events = avg_psth.event(:, event_header);
            end
            nG = size(events, 1);
            [h_event] = plot_events_on_psth(ax, table2array(events)*1000, zeros(nG,1), (1:nG)', events.Properties.VariableNames );
        end

        ylabel('Neuron #')
        xlabel('Time (s)');
end

% plot percentage of significantly modulated psths
if pct_basediff
    ax = superimpose_axes();
    plot(x, sum( comb_pBaseDiff < .05 ) / size(comb_pBaseDiff, 1) );
end
