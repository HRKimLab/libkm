function [event total_event] = get_mpsths_events(cPSTH, varargin)
% get averaged psth event as well as combined event table from PSTHs
% 1/2/2019 HRK

event_header = {};        % event headers to show on the psth (e.g., {'VSTIM_ON_CD', 'RewOn'}
b_valid_psths = [];

process_varargin(varargin);

if isempty(cPSTH) || (isstruct(cPSTH) && numel(fieldnames(cPSTH)) == 0)
    return; 
end;

if isstruct(cPSTH)
    [flist cPSTH] = sort_psth_structs(cPSTH);
end

n_psth = numel(cPSTH);

total_event = table(); total_event_grp = [];
if isempty(b_valid_psths)
    b_valid_psths = true(n_psth, 1);
end
b_cols_intersect = 0;
for iR = 1:n_psth
    % put together events
    if b_valid_psths(iR) && isfield(cPSTH{iR}, 'event') && ~isempty( cPSTH{iR}.event )
        % I may want to check the event column matches between psths..
        if size(total_event,2) == 0 || set_equal(total_event.Properties.VariableNames, cPSTH{iR}.event.Properties.VariableNames)
            total_event = [total_event; cPSTH{iR}.event(:,:)];
            total_event_grp = [total_event_grp; (1:size(cPSTH{iR}.event,1))'];
        else % if columns does not match. take interesect
            b_cols_intersect = 1;
            inters_cols = intersect(total_event.Properties.VariableNames, cPSTH{iR}.event.Properties.VariableNames);
            total_event = [total_event(:,inters_cols); cPSTH{iR}.event(:,inters_cols)];
            total_event_grp = [total_event_grp; (1:size(cPSTH{iR}.event,1))'];
        end
    end
end
if b_cols_intersect
    warning('event Columns are not the same. Some events are missing in the population PSTH.');
end

% assign event
% compute median of individual session event tables
% grpstats does stupid thing when input is only one row...
[m_event, std_event] = grpstats([total_event{:,:}; NaN(1,size(total_event,2))], [total_event_grp; NaN(1,size(total_event_grp,2))], {@nanmedian, @std});
% assign it to averaged psth structure
m_event = array2table(m_event); 
if isempty(total_event)
    event = [];
else
    m_event.Properties.VariableNames = total_event.Properties.VariableNames;
    event = m_event;
end
% check if displayed events are well aligned across sessions (std. of events > 0.1s)
idx_not_aligned_event = find(any(std_event > 0.1, 1));
event_misaligned_header = intersect(event_header, total_event.Properties.VariableNames(idx_not_aligned_event));
if ~isempty(event_misaligned_header)
    warning('event %s is not well aligned across sessions (std > 0.1s)', sprintf('%s ',event_misaligned_header{:}) );
end