function [tbl, bVR] = filter_table(tb, group_var, group_val)

% apply filter
bVR = flag_table(tb, group_var, group_val);

% return subtable
tbl = tb(bVR,:);