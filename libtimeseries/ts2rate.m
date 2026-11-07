function rate = ts2rate( ts, onset, offset)
% TS2RATE convert timestamp data to rate using time windows
%  TS2RATE(TS, ONSET, OFFSET) assumes two things:
%    1) ts is timestamp data in milisecond unit.
%    2) onset and offset are vectors which define time windows in milisecond unit.
%    
% See also CONV2RATE, STREAM2RATE

assert(size(onset,1) == size(offset,1), 'onset and offset size does not match')
nT = size(onset,1);

rate = NaN(nT, 1);

% rate will be NaN if either onset of offset is NaN
for iT = 1:nT
   rate(iT, 1) = nnz(ts >= onset(iT) & ts < offset(iT)) / (offset(iT) - onset(iT)) * 1000;
end