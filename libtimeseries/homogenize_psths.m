function [psths x n_grp flist b_valid_psths] = homogenize_psths(cPSTH, varargin)
% homogenize psth by adjusting time range and group #
% make psths ready for plotting
% caution: psths are reordered by sort_psth_structs(). use b_valid_psths only for flist
% 2020 HRK

x = [];
n_grp = [];
adjust_x_anyway = 0;     % allow adjusting x eveen if x is not a subset of psth.x, by expending elements of psth
check_ginfo = 1;         % 1: check string-level ginfo 0: do not evoke error but warning. -1: don't do anything
psth_sort_format = [];         % 'unitkey5', 'no_sort'
repack = 1;                   % remove invalid PSTHs and repack psths. set to 0 to keep the order.

process_varargin(varargin);

psth_type = class(cPSTH);
switch(psth_type)
    case 'struct'
    [flist cPSTH] = sort_psth_structs(cPSTH, psth_sort_format);
    case 'cell'
    flist = arrayfun(@(x) sprintf('r%d', x), (1:numel(cPSTH))', 'un', false);
end

n_psth = size(cPSTH, 1);
n_grps = NaN(n_psth, 1);
b_x_match = false(n_psth, 1);
b_valid_psths = false(n_psth, 1);
n_hashs = NaN(n_psth, 1);    % hash for unq_grp_lable

% expand to multiple data points if given by range
if ~isempty(x) && numel(x) == 2
    x = x(1):(cPSTH{1}.resample_bin/1000):x(2); 
end
% use the first x if not given explicitly
if isempty(x),  
    idx_sample_psth = find(~cellfun(@isempty, cPSTH),1,'first');
    x = cPSTH{idx_sample_psth }.x; auto_x = true;
else
    auto_x = false;
end

% get group number for each psth
for iR = 1:n_psth
    if isempty(cPSTH{iR})
        warning('homogenize_psths(): psth %s is empty. ', flist{iR});
        continue;
    end
    n_grps(iR,1) = size(cPSTH{iR}.mean, 1);
    
    % intersect x if not explicitly given by argument
    if auto_x
        x = intersect(x, cPSTH{iR}.x);
    end
    
    % generate grp label hashs regardless of check_ginfo option
    if isfield(cPSTH{iR}, 'ginfo') && ~isempty(cPSTH{iR}.ginfo)
        grplabel_hashs(iR, 1) = sum(double(cat(2, cPSTH{iR}.ginfo.unq_grp_label{:})));
    else
        grplabel_hashs(iR, 1) = NaN;
    end
    if check_ginfo && isfield(cPSTH{iR}, 'ginfo') && ~isempty(cPSTH{iR}.ginfo)
       % very simple string hash by summing up all ASCII values
       n_hashs(iR, 1) = grplabel_hashs(iR, 1);
    elseif check_ginfo
        fprintf(1, 'exclude %s b/c ginfo is empty (cannot check ginfo homogeniety).\n', flist{iR});
    else
        n_hashs(iR, 1) = 0;
    end
end

% create grp_hash that uniquely represent # of grps and values of them.
% the trick is to hash the string lables of all groups and make unique number 
% encoding (# of groups, strings of lables) assuming n_grp < 10000
grp_hashs = n_hashs * 10000 + n_grps;

% unless specified by parameter, use most frequent # of groups among PSTHs
if isempty(n_grp)
    grp_hash = mode(grp_hashs);
    n_grp = mod(grp_hash, 10000);
    
    if n_grp > 1, fprintf(1, 'Use number of groups = %d for PSTHs\n', n_grp); end;
else
    % if n_grp is given, choose group hash among those with that n_grp
    bV = n_grps == n_grp;
    grp_hash = mode(grp_hashs(bV));
    n_grp = mod(grp_hash, 10000);
    
    if n_grp > 1, fprintf(1, 'Use number of groups = %d for PSTHs\n', n_grp); end;
end

ref_ginfo = [];
% total_event = table(); total_event_grp = [];
% find x values and number of groups in each psth
for iR = 1:n_psth
    % don't care about weird psths.
    if isempty(cPSTH{iR}) || ~isfield(cPSTH{iR}, 'x') || isempty(cPSTH{iR}.x) ~isfield(cPSTH{iR}, 'mean')
        n_grps(iR,1) = 0;
        continue;
    end

    % update x range of PSTH if necessary
    [cPSTH{iR} b_x_match(iR)] = adjust_psth_range(x, cPSTH{iR}, adjust_x_anyway);
    
    % only select psths with the same # of groups
%     if n_grps(iR,1) == n_grp && b_x_match(iR)
    if grp_hashs(iR,1) == grp_hash && b_x_match(iR)
        b_valid_psths(iR) = true;
    else
        fprintf(1, 'grp hash does not match. exclude %s\n', flist{iR});
        % here, I can implement adjust_psth_grp to compare ginfo and either
        % shrink or expand the group if one is subset of the other.
    end
    
    if b_valid_psths(iR) && isempty(ref_ginfo) && isfield(cPSTH{iR}, 'ginfo')
        ref_ginfo = cPSTH{iR}.ginfo;
    end
       
    % hard check ginfo
    if b_valid_psths(iR) && ~isempty(ref_ginfo) && check_ginfo
        % check if group lable strings are identical each other
       if numel(ref_ginfo.unq_grp_label) ~= numel(cPSTH{iR}.ginfo.unq_grp_label) || ...
               ~all(  strcmp(ref_ginfo.unq_grp_label, cPSTH{iR}.ginfo.unq_grp_label) ) 
           warning('unq_grp_label should match. Otherwise, set check_ginfo = 0');
           keyboard
       end
    end
end

if check_ginfo
    assert(~isempty(ref_ginfo), 'ref_ginfo is somehow empty. cannot check ginfo');
end

% print info about excluded psths
if any(~b_valid_psths)
    fprintf('homogenize_psths: excluded psths (# of grps):\n');
    for i_invalid_psths = find(~b_valid_psths)'
        if isfield(cPSTH{i_invalid_psths}, 'ginfo') && isfield(cPSTH{i_invalid_psths}.ginfo, 'sParams')
            sParams = cPSTH{i_invalid_psths}.ginfo.sParams;
        else
            sParams = '';
        end
        fprintf('%s (%d), %s\n', flist{i_invalid_psths}, n_grps(i_invalid_psths), ...
            sParams );
    end
else
    fprintf(1, 'homogenize_psths: no excluded paths (n=%d)\n', nnz(b_valid_psths));
end

if ~any(b_valid_psths)
    return;
end

% repack for usual average psth plotting 
if repack
    n_tot_psths = numel(b_valid_psths);
    n_homogenized_psths = nnz(b_valid_psths);
    
    % filter-in psths that will be plotted
    cPSTH = cPSTH(b_valid_psths);
    flist = flist(b_valid_psths);
    n_psth = numel(cPSTH);
    b_valid_psths = true(n_psth, 1);
else % often I want to keep the order (e.g., psth table)
    n_tot_psths = numel(b_valid_psths);
    n_homogenized_psths = nnz(b_valid_psths);
    
    % do not filter-in psths that will be plotted
    i_invalids = find(~b_valid_psths);
    for iInv = i_invalids(:)'
        cPSTH{iInv} = [];
    end
%     cPSTH = cPSTH(b_valid_psths);
%     flist = flist(b_valid_psths);
%      n_psth = numel(cPSTH);
%     b_valid_psths = true(n_psth, 1);
end

switch(psth_type)
    case 'struct'
        % assign output psth
        psths = struct();
        for iF = 1:n_psth
            psths.(flist{iF}) = cPSTH{iF};
        end
    case 'cell'
        psths = cPSTH;
end

% warn if grplabel has is different
if nunique(nonnans(grplabel_hashs(b_valid_psths))) > 1
   unq_grplabel_hashs = unique(grplabel_hashs(b_valid_psths));
   fprintf(1, 'homogenize_psth: warning - contents of grplabels are different\n');
   for iU = 1:numel(unq_grplabel_hashs)
       iMatchRow = find(unq_grplabel_hashs(iU) == grplabel_hashs, 1, 'first');
       fprintf(1, '%15s: ', flist{iMatchRow});
       fprintf(1, '%25s | ', cPSTH{iMatchRow}.ginfo.unq_grp_label{:});
       fprintf(1, '\n');
   end
end