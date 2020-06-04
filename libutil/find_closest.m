function [idx_in_target_array bMatch] = find_closest(find_these_elements, in_this_array, crit)
% closest match version of ismember()
% changed order of return values [idx_in_target_array bMatch] 2018 HRK
% HRK 2016
if ~is_arg('crit'), crit = inf; end;
idx_in_target_array = NaN(size(find_these_elements));
for i = 1:length(find_these_elements)
    [mval idx] = min(abs( in_this_array - find_these_elements(i) ) );
    if mval > crit
        bMatch(i) = false;
        idx_in_target_array(i) = NaN;
    elseif mval <= crit
        bMatch(i) = true;
        idx_in_target_array(i) = idx;
    else % NaN comes here
        bMatch(i) = false;
        idx_in_target_array(i) = NaN;
    end
end