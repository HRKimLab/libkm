function varargout = count_columns(sLine)
% COUNT_COLUMNS count the number of columns
% HRK 2018
nCol = 0;
cToken = {};
[tok rem] = strtok(sLine, [' ' char(9)]);
while ~isempty(rem)
    nCol = nCol + 1;
    cToken{1, nCol} = tok;
    [tok rem] = strtok(rem, [' ' char(9)]);
end

% print results when there is no return argument
if nargout == 0
    fprintf(1, 'Columns #: %d\n', nCol);
elseif nargout == 1
    varargout{1} = nCol;
elseif nargout == 2
    varargout{1} = nCol;
    varargout{2} = cToken;
end