function [m_sEvents bSkipEvents] = compute_events_on_psth(events, trigger, grp, events_header)
% compute median event timing to plot a line on psth
% a function separated from plot_events_on_psth
% 
% 2020 HRK
hP = []; mEvents = [];
n_trial = size(trigger, 1);
if ~is_arg('events_header'), events_header = {}; 
elseif isstr(events_header),  events_header = {events_header };
end

if isempty(events)
    return;
end;

% I don't need event_header if events is table
if strcmp(class(events), 'table') && numel(events_header) == 0
    events_header = events.Properties.VariableNames;
end

% if grp is not specified, use increasing trial number
if ~is_arg('grp'), grp = ones(n_trial,1); end;
assert(size(grp,1) == n_trial, 'trigger and grp must have the same # of rows');

% check size of arguments
assert(size(trigger,1) == size(events,1), 'trigger and events must have the same # of rows');
% assert(size(events,2) == length(event_label), '# of columns in events should match to the event_label');

% find group to use for color code and simple analysis.
% It is the first group with group # < 10
grpid = grp;

aligned_events = bsxfun(@minus, events, trigger);

% sort trials based on group and trial #
% [~, idx_trials] = sortrows([grp (1:n_trial)']);
% y axis is just increasing trial id.
% increasing_trialids = 1:length(idx_trials);
% increasing_trialids(isnan(idx_trials)) = NaN;
% set marker for each event
% nMarker = size(events, 1);
% keep this same as the ones in plot_events_on_raster()

% compute median of event timings, sorted by group
% [# of groups * # of evenets]
if numel(grpid) == 1
    sMedEvents = grpstats([aligned_events;aligned_events], [grpid;grpid], 'nanmedian')/1000;
else
    sMedEvents = grpstats(aligned_events, grpid, 'nanmedian')/1000;
end
m_sEvents = array2table(sMedEvents);
m_sEvents.Properties.VariableNames = events_header;

% skip plotting events if all aligned events are zero (same as trigger)
bSkipEvents = all(aligned_events == 0, 1);

% plot_event_on_psth_table(m_sEvents, 'bSkipEvents', bSkipEvents, 'n_trial', n_trial, 'ax', ax);
