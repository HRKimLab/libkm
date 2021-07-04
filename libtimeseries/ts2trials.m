function [ts_T nEvent_T] = ts2trials(msEvent, msStart_T, msFinish_T, bShowWarning, snTaken)
% msEvent: timestamps
% msStart_T: trial start index
% msFinish_T: trial end index
% snTaken: +n : first n from the start, -n : n from the last
% 
% ts_T: timestamps sorted by trial
% HRK 6/16/2015

ts_T = []; nEvent_T = [];
if numel(msEvent) == 0 || numel(msStart_T) == 0|| numel(msFinish_T) == 0,
    % this generates 1 x 0 array instead of 0 x 0, does prevent errors later
    ts_T = NaN(size(msStart_T)); nEvent_T = NaN(size(msStart_T));
    return;
end

assert(size(msStart_T,1) == size(msFinish_T,1) && size(msStart_T,2) == 1 && size(msFinish_T,2) == 1, ...
    'start and end time should be n * 1 vectors');
assert(all(nonnans(msFinish_T - msStart_T) > 0));

if ~is_arg('bShowWarning'), bShowWarning = true; end;
if ~is_arg('snTaken'), snTaken = 1; end;
nTaken = abs(snTaken);
ts_T = NaN(size(msStart_T, 1), nTaken);
nEvent_T = NaN(size(msStart_T, 1), 1);

for iT = 1:size(msStart_T, 1)
   % find events within the trial
   iValid = find(msEvent >= msStart_T(iT) & msEvent < msFinish_T(iT));
   % assign the number of event
   nEvent_T(iT) = length(iValid);
   % pass if there is no event in the trial
   if nEvent_T(iT) == 0, continue; end;
   if nEvent_T(iT) > nTaken && bShowWarning
       if snTaken > 0
%         warning('ts2trkals: Trial %d has %d occurence of %s. Only take first %d event(s)', ...
%            iT, nEvent_T(iT), inputname(1), nTaken); 
       else
%             warning('ts2trials: Trial %d has %d occurence of %s. Only take last %d event(s)', ...
%            iT, nEvent_T(iT), inputname(1), nTaken); 
       end
   end;
   % assign the timestamp of the first event
   if snTaken > 0
       iiV = 1;
        for iE = 1:min([length(iValid) nTaken])
            ts_T(iT, iE) = msEvent(iValid(iiV));
            iiV = iiV + 1;
        end
   else
       iiV = length(iValid);
       for iE = min([nTaken iiV]):-1:1
           ts_T(iT, iE) = msEvent(iValid(iiV));
           iiV = iiV - 1;
       end
   end
end

assert(size(ts_T, 2) == nTaken);