function v = hex2rgb(h)
% convert from hex to RGB
% 2019 HRK
assert(ischar(h) && length(h) == 6)
v(1) = sscanf(h(1:2), '%x')
v(2) = sscanf(h(3:4), '%x')
v(3) = sscanf(h(5:6), '%x')