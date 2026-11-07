function ss = TCN2ss(TCN)
% TCN2SS transform [time x condition x neuron] to [(time*condition) x neuron]
%   array.
% 
% See also ss2TCN, 
% 2022 HRK
nTime = size(TCN, 1);
nCond = size(TCN, 2);
nNeuron = size(TCN, 3);

ss = reshape(TCN, [nTime*nCond nNeuron]);