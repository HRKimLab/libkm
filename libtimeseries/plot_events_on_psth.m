function [hP m_sEvents] = plot_events_on_psth(ax, events, trigger, grp, events_header)
% events: nTrial * nEvent
% trigger: nTrial * 1 trigger for each trial
% event_label: labels for nEvent events
% grp: nTrial*nGrp. trials will be sorted by grp in ascending column order

hP = []; mEvents = [];
n_trial = size(trigger, 1);
if ~is_arg('events_header'), events_header = {}; 
elseif isstr(events_header),  events_header = {events_header };
end

if isempty(events)
    return;
end;

% compute median event timing. TODO: remove redundancy and use m_sEvent
% computer earlier in the plot_timecourse
[m_sEvents bSkipEvents] = compute_events_on_psth(events, trigger, grp, events_header);

plot_event_on_psth_table(m_sEvents, 'bSkipEvents', bSkipEvents, 'n_trial', n_trial, 'ax', ax);
