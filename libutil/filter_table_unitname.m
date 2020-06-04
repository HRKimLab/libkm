function [tbl, bVR] = filter_table_unitname(tb, group_val)
% filter table with rows with given unitnames
% apply filter
bV = flag_table_unitname(tb, {'unitname'}, group_val);

% return subtable
tbl = tb(bV,:);