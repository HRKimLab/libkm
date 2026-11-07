function [ax p1 avg_psths psths] = plot_mpsths_table(tb, data_tags, varargin)
% PLOT_MPSTHS_TABLE plot PSTHs from a table of dataname.
%    plot_mpsths_table(tb, data_tags, varargin) creates a battery of average PSTHs 
%      that summarize your experiments nicely. It creates a matrix of average psths.
%
%       The columns of the matrix is defined by data_tags.
%       (e.g., TAINING_D1, TRAINING_D2, ... TRAINING_LASTDAY, TELEPORT_D1).
%     
%       The row of the matrix is defined by the varargin parameters.
%       If you pass three different psths (e.g., lick, locomotion, neural
%       activity), the number of rows becomes three. As a result, a figure
%       will show psths in the following layout, with options
%       'n_row', 1, 'n_col', 4.
%
%   [lick,       D1]  [lick,       D2] [lick,       D3] [lick,       lastday]
%   [locomotion, D1]  [locomotion, D2] [lick,       D3] [locomotion, lastday]
%   [neuron,     D1]  [neuron,     D2] [lick,       D3] [neuron,     lastday]
% 
%      Note that three PSTHs are considered as one chunk of row in the n_row option.
%      If the data_tag becomes too long, it will automatically
%      create a new figrue to plot results. 
%      Note that you always need to check the N on the plot, and make sure
%      that the behavioral and neural data match well.

% 5/30/2018 HRK

uk_filter = [];
individual_psths = 1;
x = [];
n_col = [];         % number of columns
n_row = [];         % number of rows
event_header = {};  % events to show.
v_col = [];         % normalized heigh
base_sub_win = [];
mark_diff = 0;
test_diff = 1;
filter_grp = [];
check_ginfo = 1;
homogenize = 1;
y_labels = [];
subsample_x = 1;
smooth_win = [];
exact_match = 0;   % not working for now.
check_event_timing = 2; % 0: print out msg, 1: warning (might miss), 2: msg dialog (cannot miss but can ignore) 3: evoke an error (no way to miss)
grp_order_only = 0;     

% get PSTH structures from varargin
bStr = cellfun(@isstruct, varargin);
cPSTHs = varargin(bStr);
varargin = varargin(~bStr);

process_varargin(varargin);

if isstr(data_tags), data_tags = {data_tags}; end
% plot error bar when not plotting individual PSTHs
if individual_psths == 0, errbar_type = 'patch';
else, errbar_type = 'none'; end


nPlots = numel(cPSTHs);
if ~isempty(v_col) && (iscell(v_col) || isnumeric(v_col) )
   assert(numel(v_col) == nPlots, 'v_col should have same # of elements as # of plots')
elseif ~isempty(v_col) 
    error('Cannot parse v_col. check the argument');
else
    % equally spaced axis
    v_col = ones(1, nPlots) / nPlots;
end
if ~isempty(base_sub_win)
    assert(size(base_sub_win, 1) == nPlots, '# of plots (%d) and # of rows of base_sub_win (%d) should match', ...
        nPlots, size(base_sub_win, 1));
end
if is_arg('y_labels')
    assert(numel(y_labels) == nPlots, '# of y label should match # of distinct psths');
end

nTag = numel(data_tags);
if ~isempty(n_col) && ~isempty(n_row)
    p = setpanel(n_row, n_col, [],[],[], 0);
    p1 = p;
else
    p = setpanel(nTag, [], [],[],[], 0);
    p1 = p;
end

% iterate data tags and plot PSTHs in column
for iT = 1:nTag
    % get next columnar panel
    p = gnp;
    % extract dataset names from data tag 
    % (not working for now.. need to be fixed)
    fprintf(1, 'retrieve datanames using %s ...\n', data_tags{iT} );
    dname = get_datanames(tb, data_tags{iT}, 'exact_match', exact_match);
    
    p.pack('v', v_col);
    
    for iP = 1:nPlots
        ax(iP, iT) = p(iP).select();
        
        if isempty(dname)
            warning('No datanames from tag %s', data_tags{iT});
            continue;
        end
        
        if isempty(base_sub_win),  basewin = [];
        else, basewin = base_sub_win(iP, :);
        end
        % filter psths based on datanames and unitkey filter
        filt_psth = filter_psth(cPSTHs{iP}, dname, uk_filter);
        % filtere groups 
        if ~isempty(filter_grp)
            filt_psth = filter_psth_group(filt_psth, filter_grp);
        end
        if nfields(filt_psth) == 0
            continue;
        end
        
        % plot averaged psth
        [avg_psths{iP} psths{iP}] = plot_mpsths(filt_psth, 'individual_psths', individual_psths, 'errbar_type', errbar_type, ...
            'x', x, 'ax', ax(iP, iT), 'show_legend', iP == 1, 'event_header', event_header, 'base_lim', basewin, ...
            'test_diff', test_diff, 'mark_diff', mark_diff, 'check_ginfo', check_ginfo, 'homogenize', homogenize, ...
            'subsample_x', subsample_x, 'smooth_win', smooth_win, 'check_event_timing', check_event_timing, 'grp_order_only', grp_order_only); %
        % show data tag
        if iP == 1
            sT = regexprep( data_tags{iT}, '_', '\\_');
            atitle([sT '\n'], 1);
        end
        % remove common x tick lables
        if iP == nPlots
           set(ax(iP, iT), 'xminorTick','on', 'TickDir', 'out', 'tickLength', [.04 .04]) 
       else
           set(ax(iP, iT), 'xticklabel', [], 'xminorTick','on', 'TickDir', 'out', 'tickLength', [.04 .04])
        end
        if iT == 1
            if ~isempty(y_labels)
                ylabel(ax(iP, iT), y_labels{iP});
                switch(y_labels{iP})
                    case {'Lick','lick'}
                        set(ax(iP, iT), 'ylim', [0 16], 'ytick', 0:8:16);
                        ylabel(ax(iP, iT), 'Lick (licks/s)');
                    case {'Speed','speed','loc','spd'}
                        % yl = get(ax(2),'ylim');
                        set(ax(iP, iT), 'ylim', [0 30], 'ytick', 0:15:30);
                        ylabel(ax(iP, iT), 'Speed (cm/s)');
                    otherwise % remove label by default
%                         ylabel(ax(iP, iT), '');
                end
            end 
        end
       % set axis tag for group manipulation (e.g., linkaxes)
       set(ax(iP, iT), 'tag', ['plot' num2str(iP)]);
    end
end

% 