function [hT] = table2uitable(T, varargin)
% show table using uitable
% 2020 HRK

name = '';
mark_rows = []; % highlight when the value is zero

process_varargin(varargin);

T_type = class(T);
switch(T_type)
    case 'cell'
        T = cell2table(T);
    case 'double'
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

hT = uitable('Data', table2cell(T(:, bCol)),'ColumnName',T.Properties.VariableNames(bCol),...
    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position', table_pos);

if any(any(mark_rows))
    assert(size(mark_rows, 1) == size(T, 1), 'mark_rwo should have the same # of rows as the table');
    % cool colormap does not have while color. if you happen to change
    % colormap, make sure that it does not have bright white-ish color
    cmap = brighter(cool(size(mark_rows, 2)),3);
    bg_colors = ones(size(mark_rows, 1), 3) * 0.99;
    for iR = 1:size(mark_rows, 1)
        if ~any(mark_rows(iR,:), 2), continue; end
        % assgin color specific to coloring column condition
        idx_color = find(mark_rows(iR, :))
        % in case it has more than one valid condition, mix the color
        bg_colors(iR ,:) = mean(cmap(idx_color,:), 1);
    end
    fprintf(1, '%d rows are highlighted\n', nnz(any(mark_rows, 2)));
    % change background of the table
    hT.BackgroundColor = bg_colors;
end

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
   