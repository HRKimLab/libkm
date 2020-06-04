function uk = str2unitkey5(s)
% parse m123s13r1e3u2 into [mid sid rid tid uid]
% 5/18/2018 HRK
uk = [];
if ischar(s), s = {s}; end

for iR = 1:length(s)
    unitkey = s{iR};
    tmp = sscanf(unitkey, 'm%ds%dr%de%du%d');
    if length(tmp) == 3
        tmp(4) = -1; tmp(5) = -1;
    elseif length(tmp) ~= 5
        warning('Failed to interpret unitkey %s', unitkey);
        tmp = ones(1,5) * -1;
        keyboard
    end
    % assign output
    monkid = tmp(1); sid = tmp(2); runid = tmp(3);
    electid = tmp(4); unitid = tmp(5);
    
%     uk(iR,:) = [monkid sid runid electid unitid];
    uk(iR,:) = [monkid sid electid unitid];
end