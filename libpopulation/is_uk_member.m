function bV = is_uk_member(unitkeys, unit_filter, str2key_func)
% test if unitkey is the member of unit_filter using unitkey5 format
% convert string format into unitkey5, and filter-in
% 5/21/2018 HRK
if ~is_arg('str2key_func')
    str2key_func = @str2unitkey5;
end

if isempty(unit_filter)
    warning('Empty unit filter: select all');
    bV = true(size(unitkeys, 1), 1);
    return
end
        
% convert unitkeys if necessary
if ~isnumeric(unitkeys)
    unitkeys = str2key_func(unitkeys);
end


% convert unit filter if necessary
if ~isnumeric(unit_filter)
    tmp_unit_filter = str2key_func(unit_filter);
    % if unit_filter is behavior, I want to search for both behavior and neuron.
    % nullify e and u if cell and string unit_filter is behavior key
    bBeh = tmp_unit_filter(:,4) == -1 & tmp_unit_filter(:,5) == -1;
    tmp_unit_filter(bBeh, [4 5]) = NaN;
    
    unit_filter = tmp_unit_filter;
end

bV = false(size(unitkeys, 1), 1);

% iterate and compare each row instead of using ismember() for the cases
% that I put NaN in unit_filter
for iR = 1:size(unitkeys, 1)
    % subtract each row from (# of filters X 5)
    if size(unit_filter, 2) == 3
        res = bsxfun(@minus, unitkeys(iR,1:3), unit_filter);
    elseif size(unit_filter, 2) == 5
        res = bsxfun(@minus, unitkeys(iR, :), unit_filter);
    else
        error('filter should be either 3 or 5');
    end
    % match if all non-NaN elements are zero
    bMatch = res == 0;
    % mark true if filter contains NaN
%     bMatch(isnan(res)) = true;      % I have problems when uid is NaN
    bMatch(isnan(unit_filter)) = true; % just look at unit_filter. 2/16/2020 HRK
    % if unikey matches to any one of filters in unit_filter, it is match.
    bV(iR,1) = any( all(bMatch, 2) );
end