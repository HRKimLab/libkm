function uk = str2unitkey5(s) 
% parse m123s13r1e3u2 into [mid sid rid tid uid]
% 5/18/2018 HRK
uk = [];
if ischar(s), s = {s}; end

for iR = 1:length(s)
    unitkey = s{iR};
    if findstr(unitkey, 'FP')       % m112s23r1_FP0_01
        tmp = sscanf(unitkey, 'm%ds%dr%d_FP%d_%d');
    elseif findstr(unitkey, 'TT')   % m112s23r1_TT0_01
        tmp = sscanf(unitkey, 'm%ds%dr%d_TT%d_%d');
    elseif findstr(unitkey, '_N') % m112s23r1_N1
        tmp = sscanf(unitkey, 'm%ds%dr%d_N%d');
        tmp(5) = 1;
    else % m112s23r1e0u1
        if ~isempty(regexp(unitkey, 'm[0-9]+s[0-9]+r[0-9]+e[0-9]+u[0-9]+')) && isempty(regexprep(unitkey, 'm[0-9]+s[0-9]+r[0-9]+e[0-9]+u[0-9]+',''))
            tmp = sscanf(unitkey, 'm%ds%dr%de%du%d');
        elseif ~isempty(regexp(unitkey, 'm[0-9]+s[0-9]+r[0-9]+')) && isempty(regexprep(unitkey, 'm[0-9]+s[0-9]+r[0-9]+',''))
            tmp = sscanf(unitkey, 'm%ds%dr%d');
        elseif ~isempty(regexp(unitkey, 'm[0-9]+c[0-9]+r[0-9]+')) && isempty(regexprep(unitkey, 'm[0-9]+c[0-9]+r[0-9]+',''))
            tmp = sscanf(unitkey, 'm%dc%dr%d');
        elseif ~isempty(regexp(unitkey, 'm[0-9]+c[0-9]+')) && isempty(regexprep(unitkey, 'm[0-9]+c[0-9]+',''))
            tmp = sscanf(unitkey, 'm%dc%d');
            tmp(3) = -1;
        else
            warning('Failed to interpret unitkey %s', unitkey);
            tmp = NaN(1, 5);
        end
    end
    
    if length(tmp) == 3
        tmp(4) = -1; tmp(5) = -1;
    elseif length(tmp) == 4 % something is wrong.
        if unitkey(end) == 'u' % last uid is missing
            tmp(5) = NaN;
        end
    elseif length(tmp) ~= 5
        warning('Failed to interpret unitkey %s', unitkey);
        tmp = ones(1,5) * -1;
        keyboard
    end
    
    % assign output
    monkid = tmp(1); sid = tmp(2); runid = tmp(3);
    electid = tmp(4); unitid = tmp(5);
    
    uk(iR,:) = [monkid sid runid electid unitid];
end