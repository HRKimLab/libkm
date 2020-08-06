function [tbl, bVR] = filter_table(tb, group_var, group_val, varargin)
% filter table based on group val matches group_val
% 2020 HRK

match_method = 'exact';  % exact or regexp

process_varargin(varargin);

% apply filter
bVR = flag_table(tb, group_var, group_val, 'match_method', match_method);

% return subtable
tbl = tb(bVR,:);