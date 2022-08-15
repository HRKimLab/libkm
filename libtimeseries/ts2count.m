function cnt = ts2count( ts, onset, offset)
% count the number of events between onset and offset, from ts2rate
% 2022 HRK
assert(size(onset,1) == size(offset,1), 'onset and offset size does not match')
nT = size(onset,1);

cnt = NaN(nT, 1);

% cnt will be NaN if either onset of offset is NaN
for iT = 1:nT
   cnt(iT, 1) = nnz(ts >= onset(iT) & ts < offset(iT));
end