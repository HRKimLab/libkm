function ret_psth = realign_psth(psth, sTrigger)
% realign time-series variables in psth structure based on trigger
% sTrigger is either single variable or vector of time (s) for each group
% new_psth = realign_psth(psth, sMax);
% 2018 HRK
assert(isstruct(psth));
assert(size(sTrigger, 2) == 1);

% iterate psths if this is structure containing psths
if ~isfield(psth, 'x')
    ret_psth = structfun(@(x) realign_psth(x, sTrigger), psth, 'un', false);
    return;
end

[sTrigger sWinOut] = psth2time(psth, sTrigger, [0 0]);

% check # of groups in psth
nG = size(psth.mean, 1);
if size(sTrigger, 1) == 1
    sTrigger = repmat(sTrigger, [nG 1]);
end
assert( size(sTrigger,1) == nG, 'sTrigger row # should be 1 or same as # of groups in psth');

% notiong to realign for an empty psth
if isempty(psth.mean), 
    ret_psth = psth;
    return;
end

% check array size and time bin
nLen = size(psth.mean, 2);
sTimeBin = psth.x(2)-psth.x(1);

assert(sTimeBin < 0.02, 'sTimeBin is too coarse (%.3fs) to perform re-aligning psth', sTimeBin);

% find array indice that corredpond to elements of sTrigger
iTrigger = NaN(nG, 1);
for iG = 1:nG
   iTrigger(iG) = find_closest( sTrigger(iG), psth.x );
end

ret_psth = struct();
fns = fieldnames(psth); nF = numel(fns);
% realign row vector and return 
for iF = 1:nF
    fn = fns{iF};
   
   % field that needs special processing
   switch (fn)
       case 'x' % regenerate x, with the same time bin centered on zero
            ret_psth.x = (-sTimeBin * nLen):sTimeBin:(sTimeBin * nLen);
       case 'event' % realign event
           ret_psth.event = psth.event;
           for iG = 1:nG
               ret_psth.event{iG,:} = psth.event{iG,:} - sTrigger(iG);
           end
       case 'pDiff'  % variables that becomes invalid. just fill NaN.
           ret_psth.(fn) = NaN(size(psth.(fn)));
   end
   
   % skip if the variable is already copied above
   if isfield(ret_psth, fn), continue; end;
   
    % if field is not a time-series variable, just copy
   if size(psth.(fn), 2) ~= nLen 
       ret_psth.(fn) = psth.(fn);
       continue;
   end
   
   % one-row time serious variable not captured above. just copy for now.
   % one problem is that when nG = 1, this routine cannot distingiush
   % per-group time serious (e.g., mean) vs. single row statistics (e.g.,
   % pDiff). ideally, it is good to capture all pDiff-like variable and 
   % nullify above.
   if size(psth.(fn), 1) ~= nG
       ret_psth.(fn) = psth.(fn);
   else
       % realign timecourse array
       ret_psth.(fn) = array2array_fixwin( psth.(fn), iTrigger); 
   end
end