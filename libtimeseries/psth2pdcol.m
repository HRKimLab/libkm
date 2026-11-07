function psth2pdcol(stPSTH, sWin, entry, func)
% PSTH2PDCOL calculate mean response from stPSTH in the given time window and
% insert it into aPD as a new column. 
% psth2pdcol(psths, sWin, entry) mean response in the time time window (sWin) 
%   will be quantified and inserted into aPD using the entry. psths should be 
%   homogeneous (# of grooups should be same). Note that psths can hvae more than
%   one group. In that case, the # of entry should match with 
%   the number of groups in the psths.
% 
% psth2pdcol(psths, sWin, entry, func) func is used to quantify the
%   responses in the given time window.
% 
% Example:
% lick_ab_RewOn psths have a single group. Quantify mean responses using
% a [-1 0] time window, insert a column with a name 'new_AntiLick'.
% psth2pdcol(lick_ab_RewOn, [-1 0], 'new_AntiLick') 
% 
% lick_ab_RewOn psths have two groups. Others are the same as the above.
% psth2pdcol(lick_ab_RewOn, [-1 0], {'new_AntiLick_G1', 'new_AntiLick_G2'}) 
%
% Note that this uses psth2pdidx, which is doing similar to Matlab's ismember 
%   for finding matches between array and array. Instead, this finds matches 
%   between psth and aPD by comparing unitkeys.
% 
% See also psth2pdidx, psth2pd (previous version) 
%
% 2018 HRK

% retrieve aPD
aPD = evalin('base', 'aPD');
% make sure that stPSTH is struct
assert(isstruct(stPSTH), 'psth should be struct, not cell array');
% for now, sWin should be 1 X 2 vector and it allows one time window.
assert(size(sWin,1) == 1 && size(sWin,2) == 2);
% make entry as cell array if it is string.
if isstr(entry), entry = {entry}; end
% use nanmean if not given
if ~is_arg('func'), func = @(x) nanmean(x, 2); end;

% extract # of groups in psths
n_grps = structfun(@(x) size(x.mean, 1), stPSTH);
assert(nunique(n_grps) == 1, '# of groups should be unique (%s) in psths', ...
    sprintf('%.0f, ', unique(n_grps)) );

% obtain # of groups in entry
n_grp = numel(entry);

% n_grps should match!
assert(unique(n_grps) == n_grp, ...
    '# of groups should match between entry (%d) and psths (%d)', ...
    n_grp, unique(n_grps) );

% prepare to-be-inserted aPD columns
pd_vals = NaN(size(aPD,1), n_grp);

% qunatify psths using the time window
psth_val = mpsths2rate(stPSTH, 0, sWin, func);

% get indices
[b_psth idx_pd] = psth2pdidx(stPSTH);

% assign the values to the corresponding rows of the prepared columns
pd_vals(idx_pd,:) = psth_val(b_psth,:);

% register values to the aPD
add_pcd_col(entry, pd_vals);

fprintf(1, 'From %d/%d psths, %d columns are inserted into %d valid rows of aPD\n', ...
    nnz(b_psth), numel(b_psth), n_grp, numel(idx_pd) );