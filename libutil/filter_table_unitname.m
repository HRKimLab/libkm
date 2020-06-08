function [tbl, bVRow] = filter_table_unitname(tb, group_val)
% filter table with rows with given unitnames
% apply filter
bVRow = flag_table_unitname(tb, {'unitname'}, group_val);

fprintf(1, 'with %d eneities, filtered table from %d rows => %d rows\n', ...
    numel(unique(group_val)), numel(bVRow), nnz(bVRow) );
% return subtable
tbl = tb(bVRow,:);