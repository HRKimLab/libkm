function bV = flag_table(tb, group_var, group_val)
% flag table for boolean operations
% 2020 HRK
tb_for_group = tb(1, group_var);
tb_for_group(1,:) = group_val;
bV = ismember(tb(:, group_var), tb_for_group);