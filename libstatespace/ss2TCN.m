function TCN = ss2TCN(ss, nTCN)

assert( all(size(nTCN) == [1 3]), 'nTCN should be 1 * 3 array');
TCN = reshape(ss, nTCN);