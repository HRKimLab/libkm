function y = fullfact_vararg(varargin)
% full factorial using variable argument
% 5/21/2018 HRK
level = [];
for iA = 1:length(varargin)
    level(iA) = length(varargin{iA});
end

var_idx = fullfact(level);

y = NaN(size(var_idx));

for iA = 1:length(varargin)
   y(:, iA) = varargin{iA}(var_idx(:, iA)); 
end