function rate = stream2rate( stream, onset, offset, func)
% STREAM2RATE compute the average rate from stream using time windows
%   stream2rate( stream, onset, offset, func) assumes two things:
%    1) stream is data sampled at 1kHz
%    2) onset and offset are timestamps of time windows in milisecond unit.
%    Based on the two assumptions, it simply take a subset of data by using
%    a numeric vector (onset to offset) as array indice for stream.
%	 Note that it takes onset <= time <= offset (not onset <= time < offset).
%    This is important when window is small.
% 
% HRK 2016
if ~is_arg('func'), func = @nanmean; end;

assert(size(onset,1) == size(offset,1), 'onset and offset size does not match')
nT = numel(onset);

rate = NaN(nT, 1);

% rate will be NaN if either onset of offset is NaN
for iT = 1:nT
%    rate(iT, 1) = nnz(ts >= onset(iT) & ts < offset(iT)) / (offset(iT) - onset(iT)) * 1000;
    if isnan(onset(iT)) || isnan(offset(iT))
        rate(iT, 1) = NaN;
    elseif onset(iT) > length(stream) || offset(iT) > length(stream) 
        rate(iT, 1) = NaN;
    else
%         rate(iT, 1) = func( stream(onset(iT):offset(iT) ) );
        rate(iT, 1) = func( stream( int32(onset(iT)):int32(offset(iT)) ) );
    end
end