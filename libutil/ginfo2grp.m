function grp = ginfo2grp(ginfo, trial_start)
% GINFO2GRP do some sanity checks and return grp
% 2018 HRK
assert(isstruct(ginfo));

% ginfo.grp_idx should be positive except NaN, and the # of unique
% values should be same as # of labels.
% Therefore, what matters most in terms of grouping, it is simply
% 'grp_idx' and 'unq_grp_label', which is the label indexed by grp_idx.
assert(size(ginfo.grp,1) == size(ginfo.grp_idx,1));
assert((size(ginfo.grp,1) == size(trial_start,1)) || numel(trial_start) == 1);
assert(length(ginfo.grp_label) == size(ginfo.grp,2) || length(ginfo.grp_label)==0);
assert(size(ginfo.unq_grp, 1) == length(ginfo.unq_grp_label) );
assert( nunique(ginfo.grp_idx) == length(ginfo.unq_grp_label) );
% OK. ginfo passed sanity check.
grp = ginfo.grp_idx;