function show_values(cTable, v)
% show unitname and values in uitable to verify numbers
% 2020 HRK

if isnumeric( cTable ) && size(cTable, 2) == 5 % cTable is unitkey5
    cTable = unitkey2str ( cTable(:, 1:5) );
end
assert(all(size(cTable, 1) == size(v, 1)), '# of rows in cTable and value should match');
cV = arrayfun(@num2str, v, 'un', false);
cData  = [cTable cV];
figure;
hT = uitable();
set(hT, 'units','normalized', 'Data', cData, 'ColumnWidth', {100,100}, 'position', [.05 .05 .9 .9]);
