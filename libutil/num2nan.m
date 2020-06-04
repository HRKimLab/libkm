function y = num2nan(x)
% convert 0 to NaN and the rest to 1
% 7/24/2016 HRK

y = NaN(size(x));
y( x ~= 0 ) = 1;