function [st sBorder] = serialize_single_psth(st, start_win, end_win)
% serialize psth with potnetially multiple groups
% 2018 HRK
if isempty(st)  % empty can happen for table psth
    st = []; sBorder = [];
    return;
end

% serialize a single psth
psth = st;
nG = size(st.mean, 1);
% if trigger is single value, make it same as nG
if isstr(start_win)
    sTrigStart = psth.event{:, {start_win}};
elseif iscell(start_win)
    assert(numel(start_win) == 1, 'only one column name should be used');
    sTrigStart = psth.event{:, start_win};
elseif isnumeric(start_win) && numel(start_win) == 1
    sTrigStart = repmat(start_win, [nG, 1]);
elseif isnumeric(start_win) && numel(start_win) == nG
    % good. do nothing
    sTrigStart = start_win;
end

% if trigger is single value, make it same as nG
if isstr(end_win)
    sTrigEnd = psth.event{:, {end_win}};
elseif iscell(end_win)
    assert(numel(end_win) == 1, 'only one column name should be used');
    sTrigEnd = psth.event{:, end_win};
elseif isnumeric(end_win) && numel(end_win) == 1
    sTrigEnd = repmat(end_win, [nG, 1]);
elseif isnumeric(end_win) && numel(end_win) == nG
    % good. do nothing
    sTrigEnd = end_win;
end

comb_mean = []; comb_sem = [];
comb_x = []; comb_roc = [];
comb_event = table();
iBorder = 0;
dx = psth.x(2) - psth.x(1);
n_nullified_events = 0;
% iterate group
for iG = 1:nG
    % get time of interest
    bV = psth.x >= sTrigStart(iG) & psth.x < sTrigEnd(iG);
    % crop mean activity and concatenate to make serialized row vector
    comb_mean = [comb_mean psth.mean(iG, bV)];
    comb_sem = [comb_sem psth.sem(iG, bV)];
    if isfield(psth, 'roc') && ~isempty(psth.roc)
        comb_roc = [comb_roc psth.roc(iG, bV)];
    end
    
    % get x range for this group
    xl = minmax(psth.x(bV));
    % register event
    if ~isfield(psth, 'event'), psth.event = table(); end
    % register group start as an event
    comb_event{1, {['CC_START' '_G' num2str(iG)]} } = iBorder(end) * dx;
    % convert existing events
    for iE = 1:size(psth.event, 2)
        header = psth.event.Properties.VariableNames{iE};
        % keep cancatenated events in seconds
        if psth.event{iG, iE} >= xl(1) && psth.event{iG, iE} <= xl(2)
            comb_event{1, {[header '_G' num2str(iG)]} } = ...
                iBorder(end) * dx + (psth.event{iG, iE} - xl(1));
        else
            % nullify event that is out of range
            comb_event{1, {[header '_G' num2str(iG)]} } = NaN;
            n_nullified_events = n_nullified_events  + 1;
        end
        
    end
    
    % accumulate x range information
    comb_x = [comb_x psth.x(bV)];
    % iBorder is the number of cumulative data points for each group
    iBorder = [iBorder numel(comb_x)];
end

% remove the first zero
iBorder = iBorder(2:end);

if n_nullified_events > 0
%     fprintf(1, 'total %d events were nullified since they were out of range\n', n_nullified_events);
end
comb_x = (0:(numel(comb_x))-1) .* (dx);
sBorder = comb_x(iBorder);
nT = nansum(st.n_grp);

% see also cat_tpsths.m for similar routine. may come up with a common
% routine later.
st.x = comb_x;
st.mean = comb_mean;
st.sem = comb_sem;
st.roc = comb_roc;
st.std = NaN(size(st.x));
st.numel = ones(size(st.x)) * nT;
st.pDiff = NaN(size(st.x));
st.pBaseDiff = NaN(size(st.x));
st.gname = 1;
st.idx_sorted_by_num = 1;
st.gnumel = NaN;
st.n_grp = sum(st.n_grp);
if ~isempty(comb_event)
    st.event = comb_event;
end