function [conc_tpsths sConcBorder sBorders] = cat_tpsth(tpsths, tpsths_unitname, cStartWin, cEndWin, varargin)
% concatenate 2D psths ([# neurons * # protocols]) horizontally 
% serialize individual psths (possbly more than one groups).
% and then concatenate them for further analysis or population plot
% use the unitname of the first column to represent the combined signal.
% 2020 HRK

auto_start = 0; auto_end = 0;
check_ginfo = 1;
show_xlim = 0;      % show individual xlim to detect psths that narrow down x
rownames = {};      % identifies for rowname. I can use tpsths_unitname, but this could be more useful
rows = 'all';       % how to process a row with an empty entity. 'all'|'pairwise' follow 'rows' option in corr()
x_by = 'psth'       % set x by 'psth' | 'grp' or 'group'

process_varargin(varargin);

if ~is_arg('cStartWin'), auto_start = 1; end
if ~is_arg('cEndWin'), auto_end = 1; end

% check errors
psth_type = class(tpsths);
switch(psth_type)
    case 'cell'
    otherwise
        error('Only cell array is allowed for now.');
end

% homogenize psths for each column
c_xls = []; c_xls_header = {};
for iC = 1:size(tpsths, 2)
    switch(x_by)
        case 'psth' % set valid x by looking at the range of psth.x
            if show_xlim
                xls = cellfun(@(x) get_x_range(x), tpsths(:,iC),'un',false);
                % concatenate xlim [start end] infos
                c_xls = [c_xls arrayfun(@(x) x, cat(1, xls{:}),'un',false ) ]; % tpsths_unitname(:, iC)
                % generate header for the xlim infos
                c_xls_header = {c_xls_header{:}, sprintf('C%d_Start', iC), sprintf('C%d_End', iC)};
            end
            fprintf(1, 'homogenize psths on column %d...\n', iC);
            tpsths(:, iC) = homogenize_psths(tpsths(:, iC), 'repack', 0, 'check_ginfo', check_ginfo);
            % double check that x range is same
            tmp = cellfun(@get_x_range, tpsths(:, iC), 'un',false) ;
            x_range = cat(1, tmp{:});
            assert(size(x_range, 1) == size(tpsths, 1));
            % x range matches except for the invalid psths.
            unq_x_start = nonnan_unique(x_range(:,1));
            unq_x_end = nonnan_unique(x_range(:,2));
            
            assert(numel( unq_x_start  ) == 1 && numel(unq_x_end ) == 1);
            
            if auto_start
                cStartWin{iC} = unq_x_start;
            end
            if auto_end
                cEndWin{iC} =   unq_x_end;
            end
            
        case {'grp','group'} % set x range by intersection of x range for each group across psths
            xls = cellfun(@(x) get_x_range_grp(x), tpsths(:,iC),'un',false);
            n_grps = cellfun(@(x) size(x, 1), xls);
            % check empty psth
            bEmptyPSTH = cellfun(@(x) numel(x) == 1, xls);
            % assign NaNs (# of group * 2) with the first valid psth
            iEmptyPSTHs = find(bEmptyPSTH);
            for iE = iEmptyPSTHs(:)'
                xls{iE} = NaN(mode(n_grps), 2) ;
            end
            tmp=cellfun(@(x) reshape(x', [numel(x(:)) 1])', xls,'un',false);
            xls_grp = cat(1, tmp{:});
            
            c_xls = [c_xls arrayfun(@(x) x, xls_grp,'un',false ) ]; % tpsths_unitname(:, iC)
            for iG=1:(size(xls_grp, 2)/2)
                % generate header for the xlim infos
                c_xls_header = {c_xls_header{:}, sprintf('C%dG%d_Start', iC, iG), sprintf('C%dG%d_End', iC, iG)};
            end
            
            % get intersect of per-group x range
            x_ranges_grp = cat(3, xls{:});
            if auto_start
                cStartWin{iC} = nanmax(x_ranges_grp(:,1,:), [], 3);
            end
            if auto_end
                cEndWin{iC} =   nanmin(x_ranges_grp(:,2,:), [], 3);
            end
    end
end


% iterate column of psths 
ser_tpsths = {};
for iC = 1:size(tpsths, 2)
    % serialize psths having different groups using stand and end win obtained above
    [ser_tpsths(:, iC) sBorders{iC}] = serialize_psths(tpsths(:, iC), cStartWin{iC}, cEndWin{iC} );
end

% now iterate each row and concatenate horizontally
for iR = 1:size(ser_tpsths, 1)
    % check validity of each row
    bInvC = cellfun(@isempty, ser_tpsths(iR, :)) ;
    switch(rows)
        case 'all' % if any of the psth is empty in the given row, invalidate the row.
            if any(bInvC)
                conc_tpsths{iR, 1} = [];
                continue;
            end
        case 'pairwise'
            iInvC = find(bInvC);
            for iC = iInvC(:)'
                % find first valid psth in the column
                iR_valid_sample_in_iC = find(~cellfun(@isempty, ser_tpsths(:, iC)), 1, 'first');
                ser_tpsths{iR, iC} = nullify_psth( ser_tpsths{iR_valid_sample_in_iC, iC} );
            end
    end
    
    comb_mean = []; comb_sem = [];
    comb_x = []; comb_roc = [];
    
    iBorder = [];

    % iterate psths
    for iC = 1:size(ser_tpsths, 2)
        psth = ser_tpsths{iR, iC};
        assert(size(psth.mean, 1) == 1, 'group # should be 1 for cancatenation');
        comb_mean = [comb_mean psth.mean];
        comb_sem = [comb_sem psth.sem];
        comb_x = [comb_x psth.x];
        comb_roc = [comb_roc psth.roc];
        iBorder = [iBorder numel(comb_x)];
    end
    
    % regenerate x
    comb_x = (1:numel(comb_x)) .* (comb_x(2)-comb_x(1));
    sConcBorder = comb_x(iBorder);
    nT = 1;
    
    st.x = comb_x;
    st.mean = comb_mean;
    st.sem = comb_sem;
    st.roc = comb_roc;
    st.std = NaN(size(st.x));
    st.numel = ones(size(st.x)) * nT;
    st.pDiff = NaN(size(st.x));
    st.pBaseDiff = NaN(size(st.x));
    st.gname = 1;
    st.grp = 1;
    st.idx_sorted_by_num = 1;
    st.gnumel = NaN;
    st.n_grp = 1;
    st.rate_rsp = [];
    st.p2 = NaN;
    conc_tpsths{iR, 1} = st;
end

% adjust serialized border based on cancatenated borders
for iC = 2:size(ser_tpsths, 2)
    sBorders{iC} = sConcBorder(iC-1) + sBorders{iC} - min(sBorders{iC});
end

% show xlim info
if show_xlim
   tXLs = cell2table(c_xls, 'VariableNames', c_xls_header);
   if ~isempty(rownames)
       tXLs.Properties.RowNames = rownames;
   end
   table2uitable(tXLs);
end

% get common x range of psth
function xl = get_x_range(psth)
if isempty(psth)
    xl = [NaN NaN];
else
    xl = minmax(psth.x);
end

% get x range for each group
function xl = get_x_range_grp(psth)
if isempty(psth)
   xl = NaN; 
else
    for iG = 1:size(psth.mean,1)
        xl(iG, :) = minmax(psth.x(~isnan(psth.mean(iG, :) )));
    end
end
