function uk = str2unitkey(s)
% convert string to unit key numeric array [mid sid rid tid uid]
% HRK

uk = [];
if ischar(s), s = {s}; end

for iR = 1:length(s)
    unitkey = ExtractUnitInfo(s{iR});
    assert(length(unitkey) == 4 || length(unitkey) == 5);
    
    uk(iR,:) = unitkey';
end