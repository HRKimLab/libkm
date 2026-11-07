function ss = TNC2ss(TNC)
% TNC2SS transform [time x condition x neuron] to [(time*condition) x neuron]
%   array.
% 
% See also ss2TCN, 
% 2022 HRK
nTime = size(TNC, 1);
nNeuron = size(TNC, 2);
nCond = size(TNC, 3);

TCN = permute(TNC, [1 3 2]);
ss = reshape(TCN, [nTime*nCond nNeuron]);