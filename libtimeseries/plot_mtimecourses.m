function [pp, tot_ax, tot_h_psth, tot_psth] = plot_mtimecourses(ms_time, trigger, start_time, end_time, grp, varargin)
% plot multiple time courses aligned by the same trigger arguments 
% varargin can be either name - value pair, or data to be plotted
% 'titles': {Lick|Speed} is keyword
% e.g., plot_mtimecourses(motor_time, ab, st, ed, grp, ...
%             ts_lick, stream_speed, ts_spikes{:}, ...
%             'labels', labels,'titles', titles, 'event', events, 'event_header', events_header, ...
%             'xticks', xticks, 'n_row', n_row, 'n_col', n_col, 'errbar_type', 'none');
% 
% 2019 HRK

% caution: for now, these arguments 
pp = [];
n_col = [];
n_row = [];
labels = [];        % deprecated. use y_lables
y_labels = [];
titles = {};
xticks = [];
% split_v is reserved for plot_timecourse. don't use it as param,'value'
% pairs are also passed to plot_timecourse. 
v_split = [];
xdist = [];
show_legend = '';
grp_lim = 10;
errbar_crit = 5;
large_scale = 0; % large-scale recording. automatically generate next figures.

% recognize ('param', value) pair to separate it from a set of data
iA = 1; iPV = [];
while iA <= numel(varargin)
    % figure out if the vararg is string
    if ischar( varargin{iA} ) && iA < numel(varargin)
        iPV = [iPV iA iA+1];
    end 
    if strcmp( varargin{iA}, 'parent_panel')
        error('parent_panel cannot be used since it is given');
    end
    iA=iA+1;
end
% save param, 'value' pairs to pass it to plot_timecourse function
cPV_orig = varargin(iPV);
% cV is cell array of data to be plotted, excluding param=value
cV = varargin(setdiff(1:numel(varargin), iPV));
% get # of data types
nV = numel(cV);
time_lim = minmax(ms_time);

% TODO; make it faster by active scanning and separate param=value pairs
process_varargin(cPV_orig);
% check label number
if is_arg('labels'), y_labels = lables; end   % for backward compatibility
if is_arg('y_labels'), assert(numel(y_labels) == nV, '# of label should be same as # of data'); end
% make sure varargin variables are numeric unless they are name/value pairs
for iV = 1:nV
    assert( isnumeric( cV{iV} ), 'variable arguments excluding name/value pairs should be numeric, not %s', class(cV{iV}) );
end

if ~is_arg('n_row') && ~is_arg('n_col')
    if nV <= 4, n_row = 2; n_col = 2; 
    elseif nV <= 6, n_row = 2; n_col = 3;
    elseif nV <= 9, n_row = 3; n_col = 3;        
    elseif nV <= 12, n_row = 3; n_col = 4;
    elseif nV <= 15, n_row = 3; n_col = 5;
    elseif nV <= 20, n_row = 4; n_col = 5;
    else, error('set either n_row or n_col'); 
    end
elseif ~ischar(n_row)  && ~ischar(n_col)
    if is_arg('n_row') && is_arg('n_col') && ~large_scale
        assert(n_col * n_row >= nV);
    elseif is_arg('n_row') && ~is_arg('n_col')
        n_col = ceil(nV/n_row);
    elseif ~is_arg('n_row') && is_arg('n_col')
        n_row = ceil(nV/n_col);
    end
else % n_row = 'h' or 'v' and n_col is split ratio
    
end
if large_scale
    pp = setpanel(n_row, n_col, '', 1, [], 0);
else
    if isempty(pp)
        create_figure('', 0);
        pp = panel_ext();
    elseif ishandle(pp)
        figure(pp);
        pp = panel_ext();
    end
    % pack panel
    if isempty(v_split)
        pp.pack(n_row, n_col);
    else % I should do 'v' before 'h' to get the same order of array index
        pp.pack('v', v_split, 'h', 1);
    end
end

% have some margin for axis labels
pp.marginright = 0;
pp.marginleft = 13;
% reduce inter-panel margins
for iR = 1:n_row
    pp(iR).marginleft = 0;
end
% decrease margin between subpanels
if isempty(titles)
    pp.margintop = 5; pp.marginbottom = 5;
else
    pp.margintop = 10; pp.marginbottom = 10;
end

% iterate data and call plot_timecourse
iR = 1; iC = 1;
tot_psth = {};
% do not pre-assign container variable. this makes the handle to be double, not
% innate graphic object. This prevent us from using some advanced graphic
% functions (e.g., getframe)
% tot_ax = []; tot_h_psth = []; 
for iV = 1:nV
    if isempty(titles)
        win_len = 100;
    else
        switch(titles{iV})
            case 'Lick' % use 200ms window for lick
                win_len = 200;
            otherwise
                win_len = 200; % 200ms for spikes
        end
    end
    if iV == 1 && ~isempty(show_legend)
        % leave some space for outside legend
        % In case of outisde psth label, it seems like that first the psth
        % axes become samll when outisde legend is created. Later, when I
        % call p.pack() for other axis, somehow panel object update the
        % already created panels and restores initial position and size.
        % As a plot panel has the same size as the one without legend, and
        % legend is located at the bottom of splot_v space. [0.2]
        cPV = {cPV_orig{:}, 'show_legend', 'psthoutside', 'split_v', [.5 .3]};
    else
        cPV = cPV_orig;
    end
    if large_scale
        parent_panel = gnp;
    else
        parent_panel = pp(iR, iC);
    end
    
    if ~isempty(xdist)
        [ax, h_psth, psth] = plot_timecourse(xdist, cV{iV}, trigger, start_time, end_time, grp, ...
            'parent_panel', parent_panel, 'win_len', win_len, cPV{:});
    elseif numel(cV{iV}) == numel(ms_time) % stream
        [ax, h_psth, psth] = plot_timecourse('stream', cV{iV}, trigger, start_time, end_time, grp, ...
            'parent_panel', parent_panel, cPV{:});
    else % timestamp
        [ax, h_psth, psth] = plot_timecourse('timestamp', cV{iV}, trigger, start_time, end_time, grp, ...
            'parent_panel', parent_panel, 'win_len', win_len, cPV{:});
    end
    
    tot_ax(:, iV) = ax;
    tot_h_psth(:, :, iV) = h_psth;
    tot_psth{iV} = psth;
    
    
    % simplify raster 
    reduce_axis_tick(ax(1));
    
    % adjust titles
    if isempty(titles)
        title(ax(1), '');
    else
        if iV == nV
            atitle(ax(1),titles{iV}); 
        else
            title(ax(1), titles{iV});
        end
        % customize ylim
        switch(titles{iV})
            case 'Lick'
                set(ax(2), 'ylim', [-1 16], 'ytick', 0:8:16);
                ylabel(ax(2), 'Lick (licks/s)');
            case 'Speed'
                %             yl = get(ax(2),'ylim');
                set(ax(2), 'ylim', [-1 30], 'ytick', 0:15:30);
                ylabel(ax(2), 'Speed (cm/s)');
            otherwise % remove label by default
                ylabel(ax(2), '');
        end
    end

    % put given label if exists
    if ~isempty(y_labels), ylabel(ax(2), y_labels{iV}); end
    
    % delet y label ('Trial')
    ylabel(ax(1), '');
    set(ax, 'Tickdir', 'out', 'TickLength', [0.025 0.025]);
    
    if iC == 1
        
    else
        set(ax(1), 'yticklabel', []);
    end
    
    % left bottom panel
    if iR == n_row % iC == 1 && iR == n_row
    else
        % delete x axis tick labels
        set(ax, 'xticklabel', []);
    end
    
    % set x ticks
    if ~isempty(xticks)
        set(ax, 'XTick', xticks);
    end
    
    if iV == 1 && ~isempty(show_legend)
        hLd = findobj(gcf,'type','legend');
        set(hLd, 'fontsize', 7);
    else
        % delete legend
        legend(ax(2), 'off');
    end
    
    % iterate panels, row first
    iR = iR + 1;
    if iR > n_row
        iR = 1; iC = iC + 1;
    end
end

% link axes
linkaxes_ext(tot_ax(:), 'x');
linkprop(tot_ax(:), 'xtick');
