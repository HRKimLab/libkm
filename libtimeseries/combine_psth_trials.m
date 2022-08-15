function [x rate_rsp borders TrTimePsth] = combine_psth_trials(cPSTH, varargin)
% combine trials (rate_rsp) from multiple psths
% make 2D array of (# of combined trials) * (# of time points) and 
% (# of max trials) * (# of time points) * (# of psths)
% 10/2019 HRK

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
grp_xlim = [];
base_lim = [];
event_header = {};        % event headers to show on the psth (e.g., {'VSTIM_ON_CD', 'RewOn'}
individual_events = 0;    % show individual events
test_diff = 1;
adjust_x_anyway = 0;     % allow adjusting x eveen if x is not a subset of psth.x, by expending elements of psth
tag_grp = 0;             % tag individual groups for condition-by-condition presentation
mark_diff = 0;

% process options
process_varargin(varargin);

avg_psth = []; comb_means = []; h_avgpsth = []; h_psth = []; h_event = [];
if isempty(cPSTH) || (isstruct(cPSTH) && numel(fieldnames(cPSTH)) == 0)
    return; 
end;

if isstruct(cPSTH)
    % sort it basedon unitkey
    [flist cPSTH] = sort_psth_structs(cPSTH);
end

bE = cellfun(@isempty, cPSTH);
if nnz(bE) > 0
    warning('Empty PSTH structure (%d). skip those', nnz(bE));
    cPSTH(bE) = [];
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

% total_event = table(); total_event_grp = [];
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
        
        tmp = plot_psma(cPSTH{iR}, 'none', brighter(brighter(brighter(line_color))), 'mark_diff', mark_diff, ...
            'show_legend', 0, 'ax', ax, 'grp_xlim', grp_xlim, 'base_lim', base_lim, 'event_header', tmp_header, 'tag_grp', tag_grp);
        h_psth = [h_psth; tmp];
    end
    
%     % put together events ( moved to get_mpsths_events() ) 
%     if b_valid_psths(iR) && isfield(cPSTH{iR}, 'event') && ~isempty( cPSTH{iR}.event )
%         % I may want to check the event column matches between psths..
%         if size(total_event,2) == 0 || set_equal(total_event.Properties.VariableNames, cPSTH{iR}.event.Properties.VariableNames)
%             total_event = [total_event; cPSTH{iR}.event(:,:)];
%             total_event_grp = [total_event_grp; (1:size(cPSTH{iR}.event,1))'];
%         else
%             inters_cols = intersect(total_event.Properties.VariableNames, cPSTH{iR}.event.Properties.VariableNames);
%             total_event = [total_event(:,inters_cols); cPSTH{iR}.event(:,inters_cols)];
%             total_event_grp = [total_event_grp; (1:size(cPSTH{iR}.event,1))'];
%         end
%     end
end

if ~any(b_valid_psths)
    return;
end

rate_rsp = [];
borders = [];
szTrTimePsth = [0 size(cPSTH{1}.rate_rsp, 2), n_psth]; % size for TrTimePsth
for iR = 1:n_psth
   rate_rsp = [rate_rsp; cPSTH{iR}.rate_rsp];
   borders = [borders; size(rate_rsp, 1)];
   szTrTimePsth(1) = max([szTrTimePsth(1) size(cPSTH{iR}.rate_rsp, 1)]);
end
borders = borders(1:end-1);

% create trial * time * (# of psth) array
TrTimePsth = NaN(szTrTimePsth);
for iR = 1:n_psth
    TrTimePsth(1:size(cPSTH{iR}.rate_rsp, 1), 1:szTrTimePsth(2), iR) = ...
        cPSTH{iR}.rate_rsp;
end