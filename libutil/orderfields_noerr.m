function s = orderfields_noerr(s, cFN)
% orderfields without error.
% order the field only if it exists
% 2019 HRK
cF = fieldnames(s);
% I cannot use intersect because it messes up the given order.
% cF = intersect(cFN, cF);
bV = cellfun(@(x) any(ismember(x, cF)), cFN);
% get intersect
cFN = cFN(bV);
% order fields
s = orderfields(s, cFN);
    