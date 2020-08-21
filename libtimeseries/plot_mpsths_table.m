function ax = plot_mpsths_table(tb, data_tags, varargin)
% plot PSTHs from a table of dataname arranged by ( protocols X subjects ), 
% plot averagd psth from for each row in a columnar manner
% 5/30/2018 HRK

uk_filter = [];
individual_psths = 1;
x = [];
n_col = [];
n_row = [];
event_header = {};
v_col = [];
base_sub_win = [];
mark_diff = 0;
filter_grp = [];
check_ginfo = 1;
homogenize = 1;
y_labels = [];
subsample_x = 1;

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
if ~isempty(v_col) && iscell(v_col)
   assert(numel(v_col) == nPlots, 'v_col should have same # of elements as # of plots')
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
else
    p = setpanel(nTag, [], [],[],[], 0);
end

% iterate data tags and plot PSTHs in column
for iT = 1:nTag
    % get next columnar panel
    p = gnp;
    % extract dataset names from data tag
    dname = get_datanames(tb, data_tags{iT});
    
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
        % plot averaged psth
        plot_mpsths(filt_psth, 'individual_psths', individual_psths, 'errbar_type', errbar_type, ...
            'x', x, 'ax', ax(iP, iT), 'show_legend', iP == 1, 'event_header', event_header, 'base_lim', basewin, ...
            'mark_diff', mark_diff, 'check_ginfo', check_ginfo, 'homogenize', homogenize, 'subsample_x', subsample_x);
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