function [avg_psth comb_means h_avgpsth h_psth h_event] = plot_mpsths(cPSTH, varargin)
% superimpose cell array of multiple PSTHs in one axis and plot average of them
%  or draw image array with each row representing individual PSTHs.
% changed filename from plot_TC_psth to plot_multiple_psths
% See also asave_psth  
% 10/31/2017 HRK
x = [];
y_sigmark = [];
x_base = -1;
pct_basediff = 0;       % show % of significant baseline difference
individual_psths = 0;   % show individual PSTHs
line_color = [];
smooth_win = [];
n_grp = [];             % designate # of groups to combine
h_psth = [];
ax = [];
errbar_type = 'patch';
show_legend = 1;
plot_type = 'line';     % line or image
grp_lim = [];
base_lim = [];
event_header = {};        % event headers to show on the psth (e.g., {'VSTIM_ON_CD', 'RewOn'}
individual_events = 0;    % show individual events
test_diff = 1;
adjust_x_anyway = 0;     % allow adjusting x eveen if x is not a subset of psth.x, by expending elements of psth
tag_grp = 0;             % tag individual groups for condition-by-condition presentation

% process options
process_varargin(varargin);

avg_psth = []; comb_means = []; h_avgpsth = []; h_psth = []; h_event = [];
if isempty(cPSTH) || (isstruct(cPSTH) && numel(fieldnames(cPSTH)) == 0)
    return; 
end;

if isstruct(cPSTH)
    [flist cPSTH] = sort_psth_structs(cPSTH);
end

n_psth = size(cPSTH, 1);
n_grps_psths = NaN(size(cPSTH, 1), 1);
b_x_match = false(size(cPSTH, 1), 1);
b_valid_psths = false(size(cPSTH, 1), 1);

% expand to multiple data points if given by range
if ~isempty(x) && numel(x) == 2
    x = x(1):(cPSTH{1}.resample_bin/1000):x(2); 
end
% use the first x if not given explicitly
if isempty(x),  
    x = cPSTH{1}.x; auto_x = true;
else
    auto_x = false;
end

% get group number for each psth
for iR = 1:n_psth
    n_grps_psths(iR,1) = size(cPSTH{iR}.mean, 1);
    
    % intersect x if not explicitly given by argument
    if auto_x
        x = intersect(x, cPSTH{iR}.x);
    end
end

% unless specified by parameter, use most frequent # of groups among PSTHs
if isempty(n_grp)
    n_grp = mode(n_grps_psths);
    if n_grp > 1, fprintf(1, 'Use number of groups = %d for PSTHs\n', n_grp); end;
    
    if isempty(line_color)
        line_color = get_cmap(n_grp);
    elseif numel(line_color) < n_grp
        warning('# of color (%d) < # of groups (%d). use get_cmap', numel(line_color), n_grp);
        line_color = get_cmap(n_grp);
    end
end

total_event = table(); total_event_grp = [];
% find x values and number of groups in each psth
for iR = 1:n_psth
    % don't care about weird psths.
    if isempty(cPSTH{iR}) || ~isfield(cPSTH{iR}, 'x') || isempty(cPSTH{iR}.x) ~isfield(cPSTH{iR}, 'mean')
        n_grps_psths(iR,1) = 0;
        continue;
    end

    % update x range of PSTH if necessary
    [cPSTH{iR} b_x_match(iR)] = adjust_psth_range(x, cPSTH{iR}, adjust_x_anyway);
    
    % only select psths with the same # of groups
    if n_grps_psths(iR,1) == n_grp && b_x_match(iR)
        b_valid_psths(iR) = true;
    end
    
    % plot individual PSTHs.
    if strcmp(plot_type, 'line') && individual_psths && b_valid_psths(iR)
        % detemine whether to show individual events or not
        if individual_events, tmp_header = event_header;
        else tmp_header = {}; 
        end
        
        tmp = plot_psma(cPSTH{iR}, 'none', brighter(brighter(brighter(line_color))), 'mark_diff', 0, ...
            'show_legend', 0, 'ax', ax, 'grp_lim', grp_lim, 'base_lim', base_lim, 'event_header', tmp_header, 'tag_grp', tag_grp);
        h_psth = [h_psth; tmp];
    end
    
    % put together events 
    if b_valid_psths(iR) && isfield(cPSTH{iR}, 'event') && ~isempty( cPSTH{iR}.event )
        % I may want to check the event column matches between psths..
        if size(total_event,2) == 0 || set_equal(total_event.Properties.VariableNames, cPSTH{iR}.event.Properties.VariableNames)
            total_event = [total_event; cPSTH{iR}.event(:,:)];
            total_event_grp = [total_event_grp; (1:size(cPSTH{iR}.event,1))'];
        else
            inters_cols = intersect(total_event.Properties.VariableNames, cPSTH{iR}.event.Properties.VariableNames);
            total_event = [total_event(:,inters_cols); cPSTH{iR}.event(:,inters_cols)];
            total_event_grp = [total_event_grp; (1:size(cPSTH{iR}.event,1))'];
        end
    end
end

if ~any(b_valid_psths)
    return;
end

% variables for combined psths
comb_means = NaN( n_psth * n_grp, size(x, 2) );
comb_pBaseDiff = NaN( n_psth * n_grp, size(x, 2) );
comb_grp = NaN( n_psth * n_grp, 1);

% combine multiple PSMAs (peri-stimulus moving average)
for iR = 1:n_psth
    if b_valid_psths(iR)
        row_idx = ((iR-1)*n_grp+1):((iR)*n_grp);
        comb_means(row_idx, :) = cPSTH{iR}.mean;
        comb_pBaseDiff(row_idx, :) = cPSTH{iR}.pBaseDiff;
        comb_grp(row_idx) = cPSTH{iR}.gname;
    end 
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
avg_psth = compute_avggrp(x(1,:), comb_means, comb_grp, 'test_diff', test_diff, 'test_timediff', 0, 'test_bin', 100, 'x_base', x_base);

% assign ginfo
for iP = find(b_valid_psths)'
    if isfield(cPSTH{iP}, 'ginfo'), avg_psth.ginfo = cPSTH{iP}.ginfo; break; end;
end

% assign event
% compute median of individual session event tables
% grpstats does stupid thing when input is only one row...
[m_event, std_event] = grpstats([total_event{:,:}; NaN(1,size(total_event,2))], [total_event_grp; NaN(1,size(total_event_grp,2))], {@nanmedian, @std});
% assign it to averaged psth structure
m_event = array2table(m_event); 
if isempty(total_event)
    avg_psth.event = [];
else
    m_event.Properties.VariableNames = total_event.Properties.VariableNames;
    avg_psth.event = m_event;
end
% check if displayed events are well aligned across sessions (std. of events > 0.1s)
idx_not_aligned_event = find(any(std_event > 0.1, 1));
event_misaligned_header = intersect(event_header, total_event.Properties.VariableNames(idx_not_aligned_event));
if ~isempty(event_misaligned_header)
    warning('event %s is not well aligned across sessions (std > 0.1s)', sprintf('%s ',event_misaligned_header{:}) );
end

% plot averaged psth
switch(plot_type)
    case 'line' % plot averaged PSMA
        [h_avgpsth, hT, hL, h_event]  = plot_psma(avg_psth, errbar_type, darker(darker(line_color)), 'y_sigmark', y_sigmark, 'mark_diff', 0, 'ax', ax, 'show_legend', show_legend, ...
            'grp_lim', grp_lim, 'event_header', event_header, 'tag_grp', tag_grp);
        set(nonnans(h_avgpsth), 'linewidth', 2); % make avg psth line thicker
        draw_refs(0, 0, NaN, ax);
        pct_bnd = prctile(comb_means(:), [1 99]);
        yl = [pct_bnd(1) - range(pct_bnd) * 0.1 pct_bnd(2) + range(pct_bnd) * 0.1];
        ylim(yl);
%         set(h_avgpsth, 'linewidth', 2,'linestyle',':');
        
    case 'image' % draw image plot with rows for individual PSTHs
        [~,~,grp_idx] = grp2coloridx(avg_psth.grp);
        plot_continuous_array(avg_psth.x, avg_psth.rate_rsp, grp_idx, 1, ax);
        ylabel('Neuron #')
        xlabel('Time (s)');
end

stitle('%d/%d (nG=%d)', nnz(b_valid_psths), length(b_valid_psths), n_grp);

if pct_basediff
    ax = superimpose_axes();
    plot(x, sum( comb_pBaseDiff < .05 ) / size(comb_pBaseDiff, 1) );
end

% print info about excluded psths
if any(~b_valid_psths)
    fprintf('plot_mpsths: excluded psths (# of grps):\n');
    for i_invalid_psths = find(~b_valid_psths)'
        fprintf('%s (%d)\n', flist{i_invalid_psths}, n_grps_psths(i_invalid_psths));
    end
else
    fprintf(1, 'plot_mpsths: no excluded paths (n=%d)\n', nnz(b_valid_psths));
end