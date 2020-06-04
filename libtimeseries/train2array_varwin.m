function [arAligned tTime] = train2array_varwin(train, tEvent, tOn, tOff)
% train: a stream of data [1 nTime]
% tOn(i) <= tEvent(i) <= tOff(i)

tEvent = round(tEvent);
tOn = round(tOn);
tOff = round(tOff);

% if trial_start and trial_end are single, it's time relative to trigger
if numel(tOn) == 1, tOn = tEvent + tOn; end
if numel(tOff) == 1, tOff = tEvent + tOff; end

assert(length(tEvent) == length(tOn) && length(tEvent) == length(tOff), 'the size of tEvent, tOn, tOff should be same')
% actually this is not really required condition
bV = ~isnan(tEvent) & ~isnan(tOn) & ~isnan(tOff);
assert(all(tOff(bV) >= tOn(bV)) && all(tEvent(bV) >= tOn(bV)) && all(tOff(bV) >= tEvent(bV)), 'timing should be tOn < tEvent < tOff')

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