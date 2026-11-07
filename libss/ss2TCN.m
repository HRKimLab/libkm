function TCN = ss2TCN(ss, nTCN)
% SS2TCN convert [(time*condition) x neuron] to [time x condition x neuron]
%
% See also TCN2ss

assert( all(size(nTCN) == [1 3]), 'nTCN should be 1 * 3 array');
TCN = reshape(ss, nTCN);