function ss = TCN2ss(TCN)

nTime = size(TCN, 1);
nCond = size(TCN, 2);
nNeuron = size(TCN, 3);

ss = reshape(TCN, [nTime*nCond nNeuron]);