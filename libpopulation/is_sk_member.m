function bV = is_sk_member(unitnames, skfilter)
% IS_SK_MEMBER test if string unitkeys are the member of skfilter
% if skfilter is cell array, bV(k) is true if any kth element of unitnames
% matches to any of skfilter regular expression.
%
% See also is_uk_member
%
% 5/21/2018 HRK

if isstr(skfilter)
    bV = cellfun(@(x) ~isempty( regexp(x, skfilter)), unitnames);
elseif iscell(skfilter)
    bV = false(size(unitnames));
    for iU = 1:length(unitnames)
        % regular expression supports cell array of the second parameters
        bV(iU) = any(cellfun(@(x) ~isempty(x), regexp(unitnames{iU}, skfilter)));
    end
end