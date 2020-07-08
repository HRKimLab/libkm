function plot_event_on_psth_table(event, varargin)
% plot event from table structure
% 2019 HRK

if isempty(event), return; end

assert(istable(event), 'event should be table');

bSkipEvents = [];
n_trial = []; 
ax = [];
events_header = {};
color_grp = [];  % color for each group

process_varargin(varargin);

if ~is_arg('bSkipEvents'), bSkipEvents = false(1, size(event, 2) ); end
if ~is_arg('n_trial'), n_trial = 150; end
if ~is_arg('ax'), ax = gca; end
if ~is_arg('events_header'), events_header = event.Properties.VariableNames; end

% select columns based on events_header
event = event(:, events_header);

marker_list = {'rx','gx','mx','cx','yx','kx','r+','g+','m+','c+','y+','k+','rv','gv','mv','cv','yv','kv'};
color_list = {'r','g','m','c','y','k','r','g','m','c','y','k','r','g','m','c','y','k'};
% concatenated events needs long list
if size(event, 2) > numel(marker_list)
    n_duplicate = ceil(size(event, 2)/numel(marker_list));
    marker_list = repmat(color_list, [1 n_duplicate]); 
    color_list = repmat(color_list, [1 n_duplicate]);
end

if ~isempty(color_grp)
    assert(size(color_grp, 1) >= size(event, 1), '# in color_grp (%d) should be no less than the # of groups (%d)', ...
        size(color_grp, 1), size(event, 1) );
    n_color_grp = size(color_grp, 1);
    for iCG = 1:n_color_grp
        color_list{iCG} = color_grp(iCG, :);
    end
end

set(ax,'NextPlot','add');
if n_trial > 200
    msize = 2;
else
    msize = 3;
end
yl_orig = get(ax, 'ylim');
xl_orig = get(ax, 'xlim');
yl = [min([yl_orig(1) -100]) max([yl_orig(2) 100])];

% convert from table from array
ar_event = table2array(event);

% iterate events
for iE = 1:size(ar_event, 2)
    
    % for now, either color by group or color by event.
    for iG = 1:size(ar_event, 1)
        x = ar_event(iG, iE);
        if ~isempty(color_grp)
            line_color = color_list{iG};
        else
            line_color = color_list{iE};
        end
        hP(iG, iE) = line([x x], yl, 'color',line_color , 'parent', ax);
        
        if bSkipEvents(iE)
            set(hP(iG, iE), 'Visible','off');
        end
    end
    
    if size(ar_event, 2) == numel(events_header)
        set(hP(:, iE), 'tag', events_header{iE});
    else
        set(hP(:, iE), 'tag', 'event');
    end
    

end

% mark cancatenated event of exists
bCC = ~cellfun(@isempty, regexp(event.Properties.VariableNames, 'CC_START_G[0-9]*'));
x_cc = event{1, bCC};
hCC = line(x_cc, ones(size(x_cc)) * yl_orig(2), 'color', 'k', 'marker', '^',...
    'markerfacecolor', 'k', 'markersize', 4);
set(hCC, 'tag', 'CC_START');

set(ax, 'xlim', xl_orig, 'ylim', yl_orig);
set(ax, 'NextPlot','replace');

end