function varargout = plot_events(ax, events, trigger, grp, events_header)
% events: nTrial * nEvent
% trigger: nTrial * 1 trigger for each trial
% event_label: labels for nEvent events
% grp: nTrial*nGrp. trials will be sorted by grp in ascending column order

if ~is_arg('grp'), grp = ones(size(trigger)); end
% extract event header from table or struct
if ~is_arg('events_header') && istable(events)
    events_header = events.Properties.VariableNames;
    events = table2array(events);
elseif ~is_arg('events_header') && isstruct(events)
    events_header = fieldnames(events);
    events = struct2array(events);
elseif ~is_arg('events_header')
    error('event header should exist unless event is struct or table');
else
    assert(size(events, 2) == numel(events_header), 'event size ~= event header size');
end

for iAx = 1:length(ax)
    ax1 = ax(iAx);
    switch(get(ax1, 'tag'))
        case 'psth' % for psth, draw a line for each group at the median of the events
            [varargout{iAx} m_sEvents] = plot_events_on_psth(ax1, events, trigger, grp, events_header);
            
        case 'raster' % raster plot
            varargout{iAx} = plot_events_on_raster(ax1, events, trigger, grp, events_header);
            
        otherwise  % unknown plot. consider it as raster for now.
            varargout{iAx} = plot_events_on_raster(ax1, events, trigger, grp, events_header);
    end
end

if length(ax) < nargout
    varargout{length(ax) + 1} = m_sEvents;
end

return