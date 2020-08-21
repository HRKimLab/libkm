function [event total_event] = get_mpsths_events(cPSTH, varargin)
% get averaged psth event as well as combined event table from PSTHs
% check if events ar ewell alighed across psths. If not 
% 1/2/2019 HRK

event_header = {};        % event headers to show on the psth (e.g., {'VSTIM_ON_CD', 'RewOn'}
b_valid_psths = [];
check_event_timing = 2;   % 0: do nothing, 1: warning (might miss), 2: msg dialog (cannot miss but can ignore) 3: evoke an error (no way to miss)
event_std_crit = 0.1;     % std criterion (sec) to evoke an warning or error

process_varargin(varargin);

if isempty(cPSTH) || (isstruct(cPSTH) && numel(fieldnames(cPSTH)) == 0)
    return; 
end

if isstruct(cPSTH)
    [flist cPSTH] = sort_psth_structs(cPSTH);
end

n_psth = numel(cPSTH);

total_event = table(); total_event_grp = [];
missing_event_headers = {};

if isempty(b_valid_psths)
    b_valid_psths = true(n_psth, 1);
end

% accumulate common event timings across psths into total_event table.
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
            % collect missing event headers to give warning below
            tmp1 = setdiff(total_event.Properties.VariableNames, inters_cols);
            tmp2 = setdiff(cPSTH{iR}.event.Properties.VariableNames, inters_cols);
            missing_event_headers = {missing_event_headers{:} tmp1{:} tmp2{:} };
            % narrow down columns of total_event
            total_event = [total_event(:,inters_cols); cPSTH{iR}.event(:,inters_cols)];
            total_event_grp = [total_event_grp; (1:size(cPSTH{iR}.event,1))'];
        end
    end
end

% print out missing column info
if b_cols_intersect
    missing_event_headers = unique(missing_event_headers);
    warning('event columns are not the same across psths. event %s are missing in the population psth.', ...
        sprintf('%s ', missing_event_headers{:} ) );
    
end

% compute median of individual session event tables
% grpstats becomes stupid when input is only one row. atuff NaN at the bottom
[m_event, std_event] = grpstats([total_event{:,:}; NaN(1,size(total_event,2))], ...
    [total_event_grp; NaN(1,size(total_event_grp,2))], {@nanmedian, @std});

% make a table that holds median event timings
m_event = array2table(m_event); 
if isempty(total_event)
    event = [];
else
    m_event.Properties.VariableNames = total_event.Properties.VariableNames;
    event = m_event;
end

% check if displayed events are well aligned across sessions (std. of events > event_std_crit)
idx_not_aligned_event = find(any(std_event > event_std_crit, 1));
event_misaligned_header = intersect(event_header, total_event.Properties.VariableNames(idx_not_aligned_event));
% get column idx among those get called
idx_not_aligned_event_its = find(ismember(total_event.Properties.VariableNames, event_misaligned_header));
if ~isempty(event_misaligned_header)
    switch(check_event_timing)
        case 0 % print msg
            fprintf(1, 'event %s is not well aligned across sessions (max std = %s > %.1f s)', ...
                sprintf('%s ',event_misaligned_header{:}), sprintf('%.2f ', max(std_event(:, idx_not_aligned_event_its))), event_std_crit );
        case 1 % print warning
            warning('event %s is not well aligned across sessions (max std = %s > %.1f s)', ...
                sprintf('%s ',event_misaligned_header{:}), sprintf('%.2f ', max(std_event(:, idx_not_aligned_event_its))), event_std_crit );
        case 2 % show dialog
            msgbox( sprintf('event %s is not well aligned across sessions (max std = %s > %.1f s)', ...
                sprintf('%s ',event_misaligned_header{:}), sprintf('%.2f ', max(std_event(:, idx_not_aligned_event_its))), event_std_crit ) );
        case 3 % error
            error('event %s is not well aligned across sessions (max std = %s > %.1f s)', ...
                sprintf('%s ',event_misaligned_header{:}), sprintf('%.2f ', max(std_event(:, idx_not_aligned_event_its))), event_std_crit );
    end
end