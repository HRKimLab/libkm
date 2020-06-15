function bV = flag_table(tb, group_var, group_val)
% flag table for boolean operations
% 2020 HRK
if ischar(group_val)
    group_val = {group_val};
end
% make group_val column vector of cell array
group_val = group_val(:);

% makt it as a table variable
tb_for_group = tb(1:numel(group_val), group_var);
tb_for_group(1:numel(group_val),:) = group_val;

% use ismember for table type variables
bV = ismember(tb(:, group_var), tb_for_group);