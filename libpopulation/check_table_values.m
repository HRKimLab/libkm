function hT = check_table_values(T, bMark)
% print out table-shape values 
% bMark is boolean array for highlight
% 2020 HRK

% ended up adding stuff to table2uitable..
table2uitable(T, 'mark_rows', bMark);