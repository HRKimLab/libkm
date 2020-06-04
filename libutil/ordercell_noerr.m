function cOut= orderfields_noerr(cS, cFN)
% orderfields without error.
% order the field only if it exists
% 2019 HRK
cF = cS; %T.Properties.VariableNames;
% I cannot use intersect because it messes up the given order.
% cF = intersect(cFN, cF);
bV = cellfun(@(x) any(ismember(x, cF)), cFN);
% get intersect
cFN = cFN(bV);
% order fields
cOut = cFN;
    