function rate = stream2rate( stream, onset, offset, func)
% compute averaged rate from stream at events
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
        rate(iT, 1) = func( stream(onset(iT):offset(iT) ) );
    end
end