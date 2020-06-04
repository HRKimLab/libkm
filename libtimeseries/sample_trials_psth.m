function [x rsp grp] = sample_trials_psth(psth, trials, xl, shuffled_pick)
% sample trials from psth
% trials can be single value (total trial) or vector (for each condition)
% rsp : n_trials * time
% grp : n_trial * 1 vector specifying group of trials
%
% 2018 HRK

% if trials are not given, do one trial for each group
if ~is_arg('trials'), trials = ones(size(psth.n_grp)); end
% if trials are given, it should be the same size as group
assert(numel(trials) == 1 || numel(psth.n_grp) == numel(trials), ...
    '# of elements in trials should match # of groups in psth')
assert(all(trials ~= 0) )
trials = trials(:);

x = [];
nT = sum(trials);
bVT = xl(1) <= psth.x  & psth.x <= xl(2);
rsp = NaN(nT, size(psth.mean(bVT), 2) );
grp = NaN(nT, 1);
iRow = 1;
if isempty(psth.rate_rsp)
    fprintf(1, 'sample_trials_psth(): rate_rsp is empty');
    return;
end

x = psth.x(bVT);
for iG = 1:numel(psth.n_grp)
   nTrInGrp = trials(iG, 1);
   grp(iRow:iRow+nTrInGrp-1, 1) = [psth.gname(iG) * ones(nTrInGrp , 1)];
   % row index of this group in rate_rsp
   iRs = find(psth.grp == psth.gname(iG) );
   % randomly pick those row indice with repeatition
    if shuffled_pick
        iRandRs = randsample(size(psth.grp, 1), nTrInGrp, true);
    else
        iRandRs = randsample(iRs, nTrInGrp, true);
    end
   % assign response based on the random indice
   rsp(iRow:iRow+nTrInGrp-1,:)  = psth.rate_rsp(iRandRs,bVT);
   
   iRow = iRow + nTrInGrp;
end

assert(iRow == nT+1)