function [tbl, bVR] = filter_table(tb, group_var, group_val)
% filter table based on group val matches group_val
% 2020 HRK

% apply filter
bVR = flag_table(tb, group_var, group_val);

% return subtable
tbl = tb(bVR,:);