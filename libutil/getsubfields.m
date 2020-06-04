function s = getsubfields(s, cF)
% get subset of fields of struct
% 2019 HRK
% use double inhibitory to implement excitatory -
s = rmfield(s, fieldnames( rmfield(s, cF) ) );