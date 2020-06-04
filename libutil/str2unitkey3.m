function uk = str2unitkey3(s)
% parse m123s13r1e3u2 into [mid sid rid tid uid]
% 2020 HRK
uk = [];
if ischar(s), s = {s}; end

uk = str2unitkey5(s);
uk(:, 4:5) = NaN;