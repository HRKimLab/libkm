function bV = flag_table(tb, group_var, group_val, varargin)
% flag table for boolean operations
% 2020 HRK

match_method = 'exact'; % exact or regexp

process_varargin(varargin);

if ischar(group_val)
    group_val = {group_val};
end
% make group_val column vector of cell array
group_val = group_val(:);

% makt it as a table variable
tb_for_group = tb(1:numel(group_val), group_var);
tb_for_group(1:numel(group_val),:) = group_val;

switch(match_method)
    case 'exact'
        % use ismember for table type variables
        bV = ismember(tb(:, group_var), tb_for_group);
    case 'regexp'
%         bV = regexp(tb(:, group_var), tb_for_group);
        bV = ~cellfun(@isempty, regexp(tb{:, group_var}, tb_for_group{:,1}) );
        assert(all(size(bV) == size(tb(:,1))));
end