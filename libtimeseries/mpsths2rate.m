function [rate cF] = mpsths2rate(stPSTH, sTrigger, sWin, func)
% MPSTHS2RATE calculate mean response from multiple psths using a time window
% aligned by trigger. output is [# of stPSTHs, # of groups].
% see also PSTH2RATE
%
% 2018 HRK

assert(isstruct(stPSTH), 'stPSTH should be structure with psths');
assert(all(size(sWin) == [1 2]), 'sWin should be 1 X 2 vector');
if ~is_arg('func'), func = @(x) nanmean(x, 2); end;

% iterate fields
cF = fieldnames(stPSTH);
nF = numel(cF);
% use the most frequent group #
for iF = 1:nF
    assert( isfield(stPSTH.(cF{iF}), 'x') );
    n_grps(iF) = size(stPSTH.(cF{iF}).mean, 1);
end
nG = mode(n_grps);
if nG > 1, fprintf(1, 'psthstruct: use most frequent number of groups : %d groups\n', nG); end

rate = NaN(nF, nG);
% iterate psths and compute rate
for iF = 1:nF
    % otherwise I will get infinite resursive loop
    if n_grps(iF) ~= nG, 
        fprintf(1, 'psthstruct2rate: skip %s because # of group (%d) ~= (%d)\n', cF{iF}, n_grps(iF), nG);
        continue; 
    end;
    % iterate group  within a single psth
    rate(iF, :) = psth2rate( stPSTH.(cF{iF}), sTrigger, sWin, func )';
end
return;