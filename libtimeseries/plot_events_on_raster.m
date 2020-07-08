function varargout = plot_events_on_raster(ax, events, trigger, grp, event_header)
% events: nTrial * nEvent
% trigger: nTrial * 1 trigger for each trial
% event_label: labels for nEvent events
% grp: nTrial*nGrp. trials will be sorted by grp in ascending column order

n_trial = size(trigger, 1);
if isempty(events)
    hP = []; varargout{1} = [];
    return;
end;

% if grp is not specified, use increasing trial number
if ~is_arg('grp'), grp = ones(n_trial,1); end;
assert(size(grp,1) == n_trial, 'trigger and grp must have the same # of rows');
% for now event_header is not used in this function. can be used later to
% show legend in raster plot.
if ~is_arg('event_header'), event_header = {}; end; 
% check size of arguments
assert(size(trigger,1) == size(events,1), 'trigger and events must have the same # of rows');
% assert(size(events,2) == length(event_label), '# of columns in events should match to the event_label');

% nullify grp to get the correct gnumel for printout
% this is necessary to match ordering from image_continuous_array()
grp( isnan(trigger) ) = NaN;

% find group to use for color code and simple analysis.
% It is the first group with group # < 10
grp_idx = ones(n_trial, 1);
for iG = 1:size(grp,2)
    if length(nonnan_unique(grp(:, iG))) < 10
        [~, grp_idx] = ismember(grp(:,iG), nonnan_unique(grp(:,iG)) );
        break;
    end
end

if istable(events)
    aligned_events = bsxfun(@minus, events{:,:}, trigger);
else
    aligned_events = bsxfun(@minus, events, trigger);
end

% sort trials based on group and trial #
[~, idx_trials] = sortrows([grp (1:n_trial)']);
% y axis is just increasing trial id.
increasing_trialids = 1:length(idx_trials);
increasing_trialids(isnan(idx_trials)) = NaN;
% set marker for each event
nMarker = size(events, 1);
% keep this same as the ones in plot_events_on_psth()
marker_list = {'rx','gx','mx','cx','yx','kx','r+','g+','m+','c+','y+','k+','rv','gv','mv','cv','yv','kv'};
color_list = {'r','g','m','c','y','k','r','g','m','c','y','k','r','g','m','c','y','k'};
% concatenated events needs long list
if size(events, 2) > numel(marker_list)
    n_duplicate = ceil(size(events, 2)/numel(marker_list));
    marker_list = repmat(color_list, [1 n_duplicate]); 
    color_list = repmat(color_list, [1 n_duplicate]);
end


sMedEvents = grpstats(aligned_events, grp, 'nanmedian')/1000;
% skip plotting events if all aligned events are zero (same as trigger)
bSkipEvents = all(aligned_events == 0, 1);

for iAx = 1:length(ax)
    hP = [];
    ax1 = ax(iAx);
    set(ax1,'NextPlot','add');
    if n_trial > 200
        msize = 2;
    else
        msize = 3;
    end
    % iterate events
    for iE = 1:size(events, 2)
        marker = marker_list{iE};        
        hP(iE) = plot(ax1, aligned_events(idx_trials, iE)/1000, ...
            increasing_trialids, marker,'markersize', msize);
        
        if bSkipEvents(iE)
            set(hP(iE), 'Visible','off');
        end
        
        if size(events, 2) == numel(event_header)
            set(hP(iE), 'tag', event_header{iE}); 
        else
            set(hP(iE), 'tag', 'event'); 
        end
    end
    set(ax,'NextPlot','replace');
    
    varargout{iAx} = hP;
end