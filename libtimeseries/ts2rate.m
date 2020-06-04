function rate = ts2rate( ts, onset, offset)

assert(size(onset,1) == size(offset,1), 'onset and offset size does not match')
nT = size(onset,1);

rate = NaN(nT, 1);

% rate will be NaN if either onset of offset is NaN
for iT = 1:nT
   rate(iT, 1) = nnz(ts >= onset(iT) & ts < offset(iT)) / (offset(iT) - onset(iT)) * 1000;
end