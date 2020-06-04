function fid = table2uitable(T, varargin)
% show table using uitable
% 2020 HRK

name = '';
mark_zero = 0; % highlight when the value is zero

process_varargin(varargin);

if iscell(T) % TODO: process header if exists
    T = cell2table(T);
end
cT = table2cell(T);
bVC = cellfun(@is_single, cT);

bCol = all(bVC, 1);
ElmCol = T.Properties.VariableNames(~bCol);

if nnz(~bCol) > 0
    fprintf(1, 'table2uitable: %d columns with non-single numeric value are not shown\n', nnz(bCol) );
end
fid = figure;
if ~isempty(name)
    fig_title(name); 
    table_pos = [0, 0, 1, 0.92];
else
    table_pos = [0, 0, 1, 1];
end

uitable('Data', table2cell(T(:, bCol)),'ColumnName',T.Properties.VariableNames(bCol),...
    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position', table_pos);

% check if the cell one character or single value (i.e., not vector or
% array)
function b = is_single(x)

b = 1;
if isstr(x)
    return;
end
if isnumeric(x) && numel(x) == 1
    return;
end

b = 0;
   