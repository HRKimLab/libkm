function [sTrigOut sWinOut] = psth2time(psth, sTrigger, sWin)
% expand trigger to the time array 
% 2018 HRK
sTrigOut = []; sWinOut = [];

nG = size(psth.mean, 1);
% if trigger is single value, make it same as nG
if isstr(sTrigger)
    sTrigOut = psth.event{:, {sTrigger}};
elseif iscell(sTrigger)
    assert(numel(sTrigger) == 1, 'only one column name should be used');
    sTrigOut = psth.event{:, sTrigger};
elseif isnumeric(sTrigger) && numel(sTrigger) == 1
    sTrigOut = repmat(sTrigger, [nG, 1]);
elseif isnumeric(sTrigger) && numel(sTrigger) == nG
    % good. do nothing
    sTrigOut = sTrigger;
end

% size of sTrigger should be same as # of groups
assert( size(sTrigOut, 1) == nG, 'sTrigger size ~= nG');

if ~is_arg('sWin')
    return;
end

% now, compute windows
% get data point indeces for the valid time window
if size(sWin, 1) == 1
    sWin = repmat(sWin, [nG 1]); 
end

sWinOut = bsxfun(@plus, sTrigOut, sWin);
assert(size(sWin, 1) == nG, 'sWin should have 1 row or # of rows same as psth groups');