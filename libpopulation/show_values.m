function show_values(cTable, v)
% show unitname and values in uitable to verify numbers
% 2020 HRK

assert(all(size(cTable, 1) == size(v, 1)), 'size of cTable and value does not match');
cV = arrayfun(@num2str, v, 'un', false);
cData  = [cTable cV];
figure;
hT = uitable();
set(hT, 'units','normalized', 'Data', cData, 'ColumnWidth', {100,100}, 'position', [.05 .05 .9 .9]);
