function rate = stream2rateMD( stream, onset, offset, func, sampling_rate)
% STREAM2RATEMD compute the average rate from stream using time windows
%   stream2rateMD( stream, onset, offset, func):
%    onset and offset are timestamps of time windows in milisecond.
%    Based on the two assumptions, it simply take a subset of data by using
%    a numeric vector (onset to offset) as array indice for stream.
%    rate is [1 x n_neuron x n_trial].
%
% see also stream2rate
%
% HRK 2016, 2025
if ~is_arg('func'), func = @nanmean; end;

assert(size(onset,1) == size(offset,1), 'onset and offset size does not match')
nT = numel(onset);
nNeuron = size(stream, 2);

rate = NaN(1, nNeuron, nT);

% rate will be NaN if either onset of offset is NaN
for iT = 1:nT
%    rate(iT, 1) = nnz(ts >= onset(iT) & ts < offset(iT)) / (offset(iT) - onset(iT)) * 1000;
    if isnan(onset(iT)) || isnan(offset(iT))
        rate(1, :, iT) = NaN;
    elseif int32(onset(iT)/1000*sampling_rate) > length(stream) || int32(offset(iT)/1000*sampling_rate) > length(stream) 
        rate(1, :, iT) = NaN;
    else
%         rate(iT, 1) = func( stream(onset(iT):offset(iT) ) );
		% note that this assumes that Time dimension is 1st dim, and func
		% (e.g., mean) considers 2nd argument as avg-across dim.
        rate(1, :, iT) = func( stream( int32(onset(iT)/1000*sampling_rate):int32(offset(iT)/1000*sampling_rate), :) , 1);
    end
end