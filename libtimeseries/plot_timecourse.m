function [ax psth h_pt] = plot_timecourse(data_type, ts_resp, trigger, trial_start, trial_end, grp, varargin)
%PLOT_TIMECOURSE plot averaged timecourse of neural or behavioral responses.
% plot_timecourse(data_type, ts_resp, trigger, trial_start, trial_end, grp, varargin)
% data_type:
%   ‘timestamp’: e.g., spike timing or lick timing in milisecond (ms).
%   ‘stream’   : continuous data sampled at 1000Hz. the start of data acqusition is 0ms.
%   'stream_lineplot': use line plot instead of color-coded image.
%    numeric   : x(t) that covary with responses (e.g., location of animal)
%
% nT         : the number of trials or events
% ts_resp    : responses to plot
% trigger    : nT X 1 array of event timing from the start of session (SoS) in ms.
% trial_start: time from SoS (nT X 1 array) or relative to trigger (scalar value) in ms
% trial_end  : time from SoS (nT X 1 array) or relative to trigger (scalar value) in ms
% grp        : categorical variable (e.g., experimental condition) or 
%              continuous variable (e.g., movement latency) to group (sort) trials.
%
% additional options are shown below. (e.g., ..., 'win_len', 200);
% win_len    : time window for averaging
% test_diff  : do statistical test for 1) difference between groups 
%                 2) difference between baseline and after-trigger response.
% grp_lim     : maximum number of groups (default: 10)
% adjust_clim : exclude outliers (n% on both side) when color code continuse
%                response using imagesc
% clim        : directly assign clim
% psth_type   : mavg for moving average, hist for histogram (PSTH)
% hist_bin    : bin size for PSTH
% errbar_type : {'patch'|'line'|'none'}
% adj_xl      : auto-adjust use x range that >95% of values are valid
% lick        : superimpose timestamp (e.g., lick) data
% base_sub_win: window for baseline subtraction (e.g, [-1.5 -0.5] ) or rates
% convert     : 'dF/F' , etc
%
% previous output args: [ax h_psth psth x rate_rsp h_event_psth h_event_raster array_rsp] 
bPlotRawCh = false;
win_len = 100;          % 50 to 60. 1/20/2016 HRK 60 to 100 11/18/2018 HRK
plot_type = 'both';     % both, none , (raw, psth: not implemented yet)
test_diff = 0;
test_type = 'nonpar';   % 'nonpar', 'par'
grp_lim = 10;
test_bin = [];
adjust_clim = 1;        % adjust clim for imagesc to be 1-99% to exclude outliers
clim = [];
psth_type = 'mavg';     % mavg : moving average, hist: histogram
hist_bin = 200;
errbar_type = 'patch';
errbar_crit = 5;        % do not show error if n_grp is greater than this
psth_legend = 1;        % 1/0 of 'on','off'
show_legend = '';       % 'psth', 'raster', 'rastertop' this can overwrite psth_legend setting
adj_xl = 1;
parent_panel = [];      % 
split_v = [.7 .3];      % vertical split proportion for the raster and psth
lick = [];
legend_gnum = 0;
use_this_psth = [];     % pass an pre-computed trial structure for the plot (rate_rsp or array_rsp)
base_sub_win = [];  % baseline subtraction for rate computation (compute_rate)
x_base = [-1 0];    % baseline for statistical analysis (e.g., ROC; compute_avggrp)
base_rsp = [];      % directly provide baseline rate (e.g., ROC; compute_avggrp)
raster_size = [];   % size of raster dots
event = [];         % 2D array of [nT X # event] containing timestamps of events
event_header = {};  % name of evenets. size should match with the # of event above
convert = '';
resample_bin = 10;  % downsample 1/10 for fields in psth structure to reduce data size (1000Hz->100Hz)
event_on_raster = 'dot'; % 'dot' or 'line'
set_lim = 1;
roc = 0;                    % 1: do ROC analysis  2: plot ROC results by splitting psth
roc_base_grpid = [];        % compute auROC based on the specified two groups
grp_xlim = [];
cmap = [];                  % color map. see get_cmap()
show_colorbar = 1;
distance_edge = [];         % bin for z(t) (e.g., distance(t))
valid_x_crit = 0.5;         % criterion (trials in the condition) to compute valid estimator

process_varargin(varargin);

ax = [];
psth = [];    
x = []; rate_rsp = [];
ginfo = [];
h_pt.psth = []; h_pt.event_raster = []; h_pt.event = [];
h_psth = NaN(0,2); h_event_raster = []; h_event_psth = [];

% assign dummy variable in case of using provided psth. just use the whole 
% trial structure for now.
if ~isempty(use_this_psth)
    assert(isstruct(use_this_psth) && isfield(use_this_psth, 'x') && ...
       (isfield(use_this_psth, 'rate_rsp') || isfield(use_this_psth, 'array_rsp') ) && isfield(use_this_psth, 'grp') , ...
       'use_this_psth should be a struct w/ fields x, [rate_rsp or array_rsp], and grp');
   
   if isstruct(use_this_psth.grp)
       n_trial = size(use_this_psth.grp.grp_idx, 1);
   elseif isnumeric(use_this_psth.grp)
       n_trial = size(use_this_psth.grp, 1);
   else, error('Unknown grp type: %s', class(use_this_psth.grp) ); end
   
   if isfield(use_this_psth, 'rate_rsp') && isnumeric(use_this_psth.grp)
       assert(size(use_this_psth.rate_rsp, 1) == n_trial, ...
           '# of rows (trial) in rate_rsp (%d) should match with that of grp (%d)', ...
           size(use_this_psth.rate_rsp, 1), n_trial );
   elseif isfield(use_this_psth, 'array_rsp') && isnumeric(use_this_psth.grp)
       assert(size(use_this_psth.array_rsp, 1) == n_trial, ...
           '# of rows (trial) in array_rsp (%d) should match with that of grp (%d)', ...
           size(use_this_psth.array_rsp, 1), n_trial );
   end
   
   % assign dummay variables. NaN evokes errors in some routine.
   % setting trigger to zero is important to use the already-aligned event 
   % information for plot_mpsths
   [trigger trial_start trial_end] = deal(zeros(n_trial, 1));
   grp = use_this_psth.grp;
end

if size(trigger, 2) > 1, error('Use row vector( | ) for trigger'); end
n_trial = size(trigger, 1);
if roc == 2
    split_v = [.5 .5];
end

% if grp is not specified, use increasing trial number
if ~is_arg('grp'), grp = ones(n_trial,1); 
elseif islogical(grp), grp = double(grp); 
elseif isstruct(grp) && isfield(grp, 'grp_idx') % grp is ginfo structure from params2grp() function
    ginfo = grp;
    % in this case, all the internel ordering follows the index of label,
    % which is grp_idx. And the order of grpstat() in compute_avggrp should
    % be matched to the order of label both is in the ascending order.
    grp = ginfo2grp(ginfo, trial_start);
elseif isstruct(grp) % grp is structure of conditions
    n_trials = structfun( @(x) numel(x), grp);
    assert( numel(unique(n_trials)) == 1, '# of trial differ in grp struct');
    ginfo = params2grp(grp);
    grp = ginfo2grp(ginfo, trial_start);
elseif istable(grp)
    tb = grp;
    % generate param struct
    for iC = 1:size(tb, 2)
        tmp_params.(tb.Properties.VariableNames{iC}) = tb{:, iC};
    end
    ginfo = params2grp(tmp_params);
    grp = ginfo2grp(ginfo, trial_start);
end

% psth_legend
switch(psth_legend), case 'on', psth_legend = 1; case 'off', psth_legend = 0; end
switch(show_legend)
    case {'psth','psthoutside'}, psth_legend = 1;
end
 
% check size of arguments
assert(size(trigger,1) == size(trial_start,1) || numel(trial_start) == 1, '# of triggger and trial_start should match');
assert(size(trial_start,1) == size(trial_end,1) || numel(trial_start) == 1 || numel(trial_end) == 1, '# of trial_start and trial_end should match');
assert(size(trigger,1) == size(grp,1), 'trigger and grp must have the same # of rows');
assert(isempty(base_rsp) || size(base_rsp, 1) == size(trigger, 1), '# of base_rsp should be same as # of trigger');
% nullify grp to get the correct gnumel for printout
grp( isnan(trigger) | isnan(trial_start) | isnan(trial_end) ) = NaN;

% return if any of input argument is just NaN array
%if all(isnan(trigger)) || all(isnan(trial_start)) || all(isnan(trial_end)) % || all(isnan(grp))
if isempty(use_this_psth) && ( all(isnan(trigger)) || all(isnan(trial_start)) || all(isnan(trial_end)) || all(all(isnan(grp))) )
    switch(plot_type)
        case 'none'
        otherwise
            % just generate axis to avoid errors in routines that use returned axis
            [ax_raster ax_psth] = generate_axis(parent_panel, split_v);
            ax = [ax_raster ax_psth];
    end

    if strcmp(psth_type, 'hist')
       x = (trial_start:hist_bin:trial_end)/1000;
       rate_rsp = zeros(size(x));
    end
    return;
end

% NaN will not be counted in cmap, nColor, gname, gnumel 
% grpid will be still NaN.
[tmp_cmap nColor grpid gname gnumel] = grp2coloridx(grp, grp_lim);

% make sure grp is equivalent to whole-trial-based group.
if ~isempty(ginfo) && isstruct(ginfo)
   if(nColor ~= size(ginfo.unq_grp_n, 1) )
       warning('group # plotted is different from ginfo. Use data_params2grp() to generate proper ginfo');
       keyboard;
   end
   % stronger sanity check would be save used trials and compare whether
   % the seed trials are identical.
   %
   % automatic re-gererating ginfo is a bit tricky as grp is assigned from
   % ginfo above. do it carefully if I want.
end
% choose proper cmap
if isempty(cmap)
   cmap = tmp_cmap; 
end

% sort trials based on group and trial #
[~, idx_trials] = sortrows([grp (1:n_trial)']);

% compute instantaneous rates. it will be subsampled in compute_avggrp
% x, rate_rsp, array_rsp is original results (1kHz)
% psth.XX is sub-sampled results (default: 100Hz)
[x, rate_rsp array_rsp base_rate] = compute_rate(data_type, ts_resp, trigger, trial_start, trial_end, 'win_len', win_len, 'bPlotRawCh', bPlotRawCh, ...
    'base_sub_win', base_sub_win, 'distance_edge', distance_edge);

switch(convert)
    case 'dF/F'
        assert(~isempty(base_sub_win), 'you should give base_sub_win argument');
        % divide
%       rate_rsp = bsxfun(@rdivide, bsxfun(@minus, rate_rsp, base_rate), base_rate);
        rate_rsp = bsxfun(@rdivide, rate_rsp, base_rate);
    case ''
    otherwise
        error('Uknown process_rate: %s', convert);
end

% use given psth
if ~isempty(use_this_psth) 
   x = use_this_psth.x;
   if isfield(use_this_psth, 'rate_rsp')
        rate_rsp = use_this_psth.rate_rsp;
        array_rsp = rate_rsp;
   elseif isfield(use_this_psth, 'array_rsp')
       % make sure that data_type is timestamp
       assert(strcmp(data_type, 'timestamp'), 'only timestamp is supported');
       array_rsp = use_this_psth.array_rsp;
       % array_rsp should be overwritten b/c it is shrinken in compute_rate
       % by win_len
       [x rate_rsp array_rsp] = compute_rate(data_type, ts_resp, trigger, trial_start, trial_end, ...
           'x', use_this_psth.x, 'array_rsp', use_this_psth.array_rsp, varargin{:} );
   end
   % grp is already assigned up in the beginning. no need to overwrite here
%    grp = use_this_psth.grp;
   
   % baseline subtraction
   if ~isempty(base_sub_win) && all(size(base_sub_win) == [1 2])
       base_rate = mean(array_rsp (:,x >= base_sub_win(1) & x < base_sub_win(2)), 2) ;
        rate_rsp = rate_rsp - repmat(base_rate, [1 size(rate_rsp, 2)]);
   end
end

% compute averaged response and test statistical difference
psth = compute_avggrp(x, rate_rsp, grp, 'test_diff', test_diff, 'test_type', test_type, 'grp_lim', grp_lim, ...
    'test_bin', test_bin, 'resample_bin', resample_bin, 'roc', roc, 'x_base', x_base, ...
    'base_rsp', base_rsp, 'roc_base_grpid', roc_base_grpid, 'valid_x_crit', valid_x_crit);

% assign array_rsp (unaveraged raw trial structure). This won't be saved
psth.array_rsp = array_rsp;

if strcmp(psth_type, 'hist') % output: hist_edges, nHist
    [nHist hist_edges] = compute_psth(ts_resp, trigger, trial_start, trial_end, hist_bin);
end

[xl yl] = get_plot_range(psth, adj_xl);

% assign win_len for timestamp. 
if strcmp(data_type, 'timestamp') && isempty(use_this_psth)
    psth.win_len = win_len;
else    
    psth.win_len = NaN;
end
% assign ginfo for labeing
psth.ginfo = ginfo;
n_grp = grpstats( ~isnan(grpid), grpid, {'sum'} );
assert(all(psth.n_grp == n_grp)); % just for sanity check.. this and above can be removed later.
% just to avoid errors in save_key. can be commented out later.
% psth = reorderstructure(psth, 'x','mean','sem','std','numel','n_grp','pDiff','gname', 'ginfo');

% compute event info. TODO: use this one instaed of doing same thing below.
if ~isempty(event) && ~isempty(event_header)
    [m_sEvents] = compute_events_on_psth(event, trigger, psth.grpid, event_header);
    psth.event = m_sEvents;
end

% return if not plotting graphs
if strcmp(plot_type, 'none')
    ax = [];
    return; 
end

% generate axis for plots
switch (plot_type)
    case 'none'
    case 'raster'
        split_v = [0.95 0.05];
        show_colorbar = 1;
    case 'psth'
        split_v = [0.05 0.95];
        show_colorbar = 0;
    case 'both'

    otherwise
        error('Unknown plot_type: %s', plot_type);
end
[ax_raster ax_psth] = generate_axis(parent_panel, split_v);

% set tag to identify each axis
set(ax_raster, 'tag', 'raster');
set(ax_psth, 'tag', 'psth'); 

%% now, plot results
% plot trial-by-trial responses
if isnumeric(data_type) 
% ts_resp is stream
    image_continuous_array(x, rate_rsp(idx_trials,:), 'grp_idx', grpid(idx_trials), ...
        'bSkipNaN', true, 'grp_lim', grp_lim, 'xl', xl, 'ax', ax_raster, 'cmap', cmap, ...
        'adjust_clim', adjust_clim, 'clim', clim);
    set(ax_raster, 'xtick',[]);    
else
    switch(data_type)
    case 'timestamp'
        % plot raster sorted by group,
%         axes(ax_raster);
        plot_raster_array(x, array_rsp(idx_trials,:), grpid(idx_trials), true, ...
            'raster_size', raster_size, 'ax', ax_raster, 'cmap', cmap);
        set(ax_raster, 'xtick',[]);
    case {'stream'}
        % check if the user tries to smooth stream type and give warning
        % that it does not work.
        if any(strcmp(varargin, 'win_len')), warning('plot_timecourse: stream type is not smoothed by win_len.'); end;
        % plot continouse data sorted by group,
%         axes(ax_raster);
        % response from NaN trigger will have biggest idx_trials, thus be stacked
        % at the bottom of array_rsp(idx_trials,:)
        image_continuous_array(x, array_rsp(idx_trials,:), 'grp_idx', grpid(idx_trials), ...
            'bSkipNaN', true, 'grp_lim', grp_lim, 'xl', xl, 'ax', ax_raster, 'show_colorbar', show_colorbar, ...
            'adjust_clim', adjust_clim, 'clim', clim);
        
        set(ax_raster, 'xtick',[]);
    case 'stream_lineplot'
        % plot continouse data sorted by group,
        axes(ax_raster);
        line_sep = 300;
        plot_linesep(x, array_rsp', line_sep);
        set(ax_raster, 'xtick',[]);
        n_valid = nnz(~all(isnan(array_rsp),2));
        stitle(ax_raster, 'N=%d/%d(-%d)', n_valid, n_trial, n_trial - n_valid);
    end
end

% adjust y tick label
n_valid = sum(psth.n_grp);
if n_valid <= 20  % do nothing
elseif n_valid > 20 & n_valid <= 50
    set(ax_raster, 'ytick', 20:20:n_trial, 'yticklabel', 20:20:n_trial);
elseif n_valid > 50 & n_valid <= 210 % make ticks multiples of 50
    set(ax_raster, 'ytick', 50:50:n_trial, 'yticklabel', 50:50:n_trial);
elseif n_valid > 210   % make ticks multiples of 100
    set(ax_raster, 'ytick', 100:100:n_trial, 'yticklabel', 100:100:n_trial,'yticklabelmode','manual');
end

% plot additional raster
if ~isempty(lick)
    axes(ax_raster);
    [~, ar_lick] = ts2array(lick, trigger, trial_start, trial_end);
    plot_raster_array(x, ar_lick(idx_trials,:), grpid(idx_trials), true, 'raster_size', raster_size);
    % use tag = 'rastermarker' to find out lick handles
end

% move it to image_continuous_array()
% % adjust color range by percentile
% if ~isempty(findobj(ax_raster,'type','image')) && adjust_clim  ~= 0
%     sorted_rate_rsp = sort( nonnans(rate_rsp) );
%     if ~isempty(sorted_rate_rsp)
%         nlen = length(sorted_rate_rsp);
%         if nlen > 2
%             adjust_cl(1) = sorted_rate_rsp( round(nlen * adjust_clim / 100));
%             adjust_cl(2) = sorted_rate_rsp( round(nlen * (100-adjust_clim) / 100));
%             if diff(adjust_cl) > 0,  set(ax_raster,'clim', adjust_cl); end;
%         end
%     end
% end
% 
% % adjust color range by absolute value
% if ~isempty(clim)
%     set(ax_raster,'clim', clim);
% end

% mark group at the right side of plot
mark_group_on_plot(ax_raster, grpid(idx_trials), cmap, 'outside');
% re-adjust x position of markers
% adjust_grp_markers(ax_raster);

if nColor > errbar_crit
    errbar_type = 'none';
end

% plot psth
switch(psth_type)
    case 'mavg' % peri-stimulus moving average
        [h_pt.psth hT hL] = plot_psma(psth, 'eb_type', errbar_type, 'cmap', cmap, 'legend_gnum', ...
            legend_gnum,'ax',ax_psth, 'set_lim', set_lim, 'grp_xlim', grp_xlim);
    case 'hist'        
        bar(ax_psth, hist_edges, nHist, 'histc');
        xlim(ax_psth, minmax(hist_edges));
        draw_refs(0, 0, NaN);
        % In this case, change x and rate_rsp accordingly.
        x = hist_edges;
        rate_rsp = nHist';
end

% plot legend
if ~psth_legend && ~isempty(ax_psth)
   legend(ax_psth, 'off');
end
switch(show_legend)
    case 'psthoutside'
        legend(ax_psth, 'location','southoutside');
end

% set tick and reference line
if bPlotRawCh, set(ax_raster, 'ytick', [line_sep]);
elseif ischar(data_type)
    switch(data_type)
        case 'timestamp'
            ylabel(ax_psth, 'Rate (Hz)');
        otherwise
    end
end

draw_refs(0, 0, NaN, ax_psth);
% if ~isnumeric(data_type), xlabel(ax_psth, 'Time (s)'); end;

% focus on rater because I usually add title for the raster
% this slows down plotting. comment out for now.
% axes(ax_raster); 

ax = [ax_raster; ax_psth];
linkaxes(ax, 'x'); set(ax, 'xlim', xl); 

% plot events. event can be double array, table array or struct 
if isfield(psth, 'event') && ~isempty(psth.event)
    % extract event header from table or struct
    if ~is_arg('event_header') 
        if istable(event)
            event_header = event.Properties.VariableNames;
            event = table2array(event);
        elseif isstruct(event)
            event_header = fieldnames(event);
            event = struct2array(event);
        else
            error('event header should exist unless event is struct or table');
        end
    else
        if isstr(event_header), event_header = {event_header}; end
        assert(size(event, 2) == numel(event_header), 'event size ~= event header size');
    end

    % show events in psth
    if ~isempty(ax_psth)
        [h_pt.event m_sEvents] = plot_events_on_psth(ax_psth, event, trigger, psth.grpid, event_header);
        psth.event = m_sEvents;
    end
    % show events in raster
    if ~isempty(ax_raster)
        switch(event_on_raster)
            case 'dot'
%                 h_pt.event_raster = plot_events_on_raster(ax_raster, event, trigger, grp, event_header);
                h_pt.event_raster = plot_events_on_raster(ax_raster, event(idx_trials,:), trigger(idx_trials,:), grpid(idx_trials,:), event_header);
            case 'line'
                if isa(psth.event, 'table')
%                 h_pt.event_raster = plot_line_events_on_raster(ax_raster, psth.event, trigger, grp, event_header);
                h_pt.event_raster = plot_line_events_on_raster(ax_raster, psth.event, trigger, grpid, event_header);
                end
        end
    end
else
    psth.event = [];
end

% plot roc if roc == 2
if roc == 2
   % superimpose roc axis
   ax_tmp = superimpose_axes(ax_psth);
   ax_roc = ax_tmp(2);
   plot(ax_roc, psth.x, psth.roc);
   ytick(ax_roc, [0 0.5 1]);
   ylabel(ax_roc, 'auROC');
   line(minmax(psth.x), [0.5 0.5], 'color', 'k', 'linestyle', ':', 'parent', ax_roc);
end
% color bar on the right of raster makes ax_rater not be CurrentAxes.
% I tried some tweaks but did not work. make it explicit here.
set(get(ax_raster,'parent'), 'CurrentAxes', ax_raster);
    
return;
