function [arAligned tTime] = train2array_varwinMD(train, tEvent, tOn, tOff, dim_type)
% TRAIN2ARRAY_VARWINMD align train of activity using time windows, multi-dim
% train: a stream of data [nTime nNeuron] (MD)
% arAligned : dim_type = {'TNE','TNC'} : Time x Neuron x Event
%             dim_type = {'TEN','TCN'} : Time x Event x Neuron
%
% tOn(i) <= tEvent(i) <= tOff(i)
% 
% RETURN VALUES:
% arAligned: train aligned by tEvent, [nTime nTrial nNeuron] 
% tTime: time points, [1 nTime] 
% 
% see also train2array_varwin
%
% 2009 HRK
% 2025 HRK

% make sure that 1st dim (row) is time.
if size(train, 1) < size(train, 2)
	warning('train 1st dim (%d) > 2st dim (%d). Make sure this is correct.', size(train, 1), size(train, 2) );
end

nNeuron = size(train, 2);
tEvent = round(tEvent);
tOn = round(tOn);
tOff = round(tOff);

if ~is_arg('dim_type')
% 	dim_type = 'TEN';
	dim_type = 'TNE';
end

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
% arAligned = NaN(length(tEvent), t_xlim(2) - t_xlim(1) + 1, nNeuron);
switch(dim_type)
	case {'TEN','TCN'}
		arAligned = NaN(t_xlim(2) - t_xlim(1) + 1, length(tEvent), nNeuron);
	case {'TNE','TNC'}
		arAligned = NaN(t_xlim(2) - t_xlim(1) + 1, nNeuron, length(tEvent));
end

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
    
	switch(dim_type)
		case 'TEN'
	%     arAligned(iE, idx_array, :) = train(idx_train, :);
		arAligned(idx_array, iE, :) = train(idx_train, :);
		case 'TNE'
			arAligned(idx_array, :, iE) = train(idx_train, :);
		otherwise
			error('Unknown dim_type: %s', dim_type);
	end
end