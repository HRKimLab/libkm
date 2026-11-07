function bV = is_uk_member(unitkeys, unit_filter, str2key_func)
% IS_UK_MEMBER test if an array of unitkey is the member of unit_filter.
%   bV = IS_UK_MEMBER(unitkeys, unit_filter) using unitkey5 format. 
%     unitkeys: [n_rows * 5] array of unitkeys ([mid sid rid eid uid]). 
%        Usually, you provide the first five columns of the loaded aPD.0
%     unit_filter: [n_filters * 5] array of filters or cell array.
%        if cell array is given, it converts string into unitkey5.
%        
% RETURN VALUE:
%     bV is a column vector. The row number is same as unitkeys [n_rows * 1].
%
%     Note that it iterate individual rows of unikeys(iR,:), and examine filters. 
%     Filters are tested indenpendently. If any of the filters match, that
%     row will be marked as true ( bV(iR) = true ). Otherwise, it will be
%     false ( bV(iR) = false ). NaN in the unit_filter will be ignored.
%
%     bV can be used as a array index variable to filter-in aPD. 
%     The strategy of aPD framework is that you load a superset of data 
%     (a big table) once and you dissect a subset of it (e.g., specific 
%     training days) and use it for specific analyses. In this strategy,
%     boolean flag plays a key role in dissecting the big dataset.
% 
%     Tip: You can easily get a intersect of two subsets by applying
%     element-wise AND operation between the boolean flags. For example, if
%     you have bD1 for day 1 dataset and bControl for control animals, 
%     (bD1 & bControl) gives you an intersection between the two subsets. 
%     In your population analysis code, you first make a basic filters, 
%     and then in the later analysis section, you can make new boolean 
%     filters by combining them. This keeps your analysis codes simple and
%     readable.
%
% Examples:
%    The following statements generate boolean filter bV to filter-in
%    aPD rows from animal 183 and 234, and eid of 14 and uid of 1.
%    >> neuron_behavior_filt = [183 NaN NaN 14 1; 234 NaN NaN 14 1];
%    >> bV = is_uk_member(aPD(:, 1:5), neuron_behavior_filt);
%    % now you can select a subset of aPD data using the boolean filter
%    >> aPD(bV, VARIABLES_OF_INTEREST ) 
%
% See also ISMEMBER (very useful), IS_SK_MEMBER, filter_psth
%
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