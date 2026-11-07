function [arAligned tTime] = train2array_varwin(train, tEvent, tOn, tOff)
% TRAIN2ARRAY_VARWIN align train of activity using time windows
% train: a stream of data [1 nTime]
% tOn(i) <= tEvent(i) <= tOff(i)
% 
% RETURN VALUES:
% arAligned: train aligned by tEvent, [nTrial nTime] 
% tTime: time points, [1 nTime] 
% 
% see also train2array_varwinMD
%
% 2009 HRK

tEvent = round(tEvent);
tOn = round(tOn);
tOff = round(tOff);

% if trial_start and trial_end are single, it's time relative to trigger
if numel(tOn) == 1, tOn = tEvent + tOn; end
if numel(tOff) == 1, tOff = tEvent + tOff; end

assert(length(tEvent) == length(tOn) && length(tEvent) == length(tOff), 'the size of tEvent, tOn, tOff should be same')
% actually this is not really required condition
bV = ~isnan(tEvent) & ~isnan(tOn) & ~isnan(tOff);
assert(all(tOff(bV) >= tOn(bV)))
if ~all(tEvent(bV) >= tOn(bV))
    warning('timing of some tEvent < tOn')
end
if ~all(tOff(bV) >= tEvent(bV))
    warning('timing of some tOff < tEvent')
end

% find largest negative relative to the tEvent
t_xlim(1) = min(tOn - tEvent);
t_xlim(2) = max(tOff - tEvent);

tTime = t_xlim(1):t_xlim(2);

% assign output array
arAligned = NaN(length(tEvent), t_xlim(2) - t_xlim(1) + 1);

% iterate tEvent and fill
for iE = 1:length(tEvent)
    if ~bV(iE) % skip of any of the timing params is NaN
        continue;
    end
    idx_train = tOn(iE):tOff(iE);
    idx_array = ((tOn(iE)-tEvent(iE))-t_xlim(1)+1) :  ((tOff(iE)-tEvent(iE))-t_xlim(1)+1);
    
    assert(all(size(idx_train) == size(idx_array)));
    
    % train out of index
    bTrim = idx_train < 1 | idx_train > length(train);
    idx_train(bTrim) = []; idx_array(bTrim) = [];
    
    arAligned(iE, idx_array) = train(idx_train);
end