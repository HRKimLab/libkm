function [cD tD] = load_tabular_dataset_info(fpath, varargin)
% load tabular dataset from file
% First column is reserved for protocol name (anything after ', %?' is ignored)
% First row is for animal id (should be number for now)
% 
% it will ignore columns and rows that starts with '%'
% 
% 2018 HRK

delim = '\t';
debug = 0;  % 1: open only uitable  2: open both tsv file and uitable 
num_skip_lines = 0; % data to ignore 'before' the real header (simply skip lines)
num_header = 0; % data to ignore 'after' the real header

a = process_varargin(varargin);

if ~isempty(a)
    error('Please use param, value method for argument passing');
end

% assert(num_header > 0, 'number of headers should be > 0');

if ~is_arg('delim')
    [~,~,ext] = fileparts(fpath);
    switch(ext)
        case {'.tsv', '.TSV'}
            delim = '\t';
        case {'.csv', '.CSV'}
            delim = ',';
        otherwise
            delim = '\t';
    end
end
fprintf(1, 'Use ''%s'' as a delimeter. Make sure you do not have this character in the table\n', delim);
if ~is_arg('debug'), debug = 0; end;
    
fid = fopen(fpath,'r');

% skip first num_skip_lines lines
for iL = 1:num_skip_lines
    fgets(fid);
end

% get the first row without '%' for header
sLine = fgets(fid);
% while sLine(1) == '%' % no. first line should be header.
%   sLine = fgets(fid);  
% end
disp(['Header: ' sLine]);

if sprintf(delim) == sLine(1)
    warning('First character of the first line cannot be delimiter. insert %Animals in the (1,1) cell.');
    sLine = ['%Animals' sLine];
end
nCol = 0;
[tok sLine] = strtok(sLine);

while ~isempty(sLine)
    nCol = nCol + 1;
    [tok sLine] = strtok(sLine);
end

fprintf('# of columns (including row name): %d\n', nCol);

% generate format according to the number of columns
fmt = '%s';
for iC=2:nCol
    fmt = [fmt '%s'];
end

% rewind
fseek(fid, 0, -1);

% skip first num_skip_lines lines
for iL = 1:num_skip_lines
    fgets(fid);
end

% load text file into string variable
sFile = fscanf(fid, '%c');
fclose(fid);

% I should replace CR in a cell to something else (';') to run textscan
% google sheet put one space after CR ("\r ") to signal that it is CR
% within a cell
sFile = regexprep(sFile, '\r ', ';');
C = textscan(sFile, fmt, 'Delimiter', delim, 'CommentStyle','%-', 'Headerlines', num_header);
% C = textscan(fid, fmt, 'Delimiter', delim, 'CommentStyle','%-');

% trim table
cD = trim2table(C);

nRow = size(cD, 1);
fprintf('Loaded %d rows (protocols), %d columns (subjects) data table\n', nRow, nCol);

% erase rows whose names start with comment (%)
% previous method. eliminate if the first column is empty
% bElmRows = cellfun(@(x) isempty(x) || ismember(x(1), '%-'), cD(:,1));
% 8/31/2020. only eliminate if the first column contains '%-'
bElmRows = cellfun(@(x) ~isempty(x) && ismember(x(1), '%-'), cD(:,1));
% do not erase first row
bElmRows(1) = false;
tmp = cD(bElmRows, 1); fprintf(1, 'Eliminate %d rows (starting with ''%''): %s\n', nnz(bElmRows), sprintf('%s ', tmp{:}));
cD(bElmRows,:) = [];

% erase columns whose names start with comment (%)
bElmCols = cellfun(@(x) isempty(x) || ismember(x(1), '%-'), cD(1,:));
% do not erase first column
bElmCols(1) = false;
tmp = cD(1, bElmCols); fprintf(1, 'Eliminate %d columns : %s\n', nnz(bElmCols), sprintf('%s ', tmp{:}));
cD(:,bElmCols) = [];

nRow = size(cD, 1); nCol = size(cD, 2);
fprintf('Final table is %d rows, %d columns\n', nRow, nCol);

% trim comments for the first column. 
for iR = 1:nRow
    % ignore comments. only take the first token
    cD{iR,1} = strtok(cD{iR,1}, ', %?');
end
        
if debug == 2
    edit(fpath);
end
if debug >= 1
   figure;
   hT = uitable('units','normalized', 'Position', [0 0 1 1],'Data', cD);
   % mark redundant units
end

% convert it to table
tD = cell2table(cD(2:end,:), 'VariableNames', cellfun(@conv_header, cD(1, :),'un',false));

% assign rowname if unique
if numel(tD(:,1)) == numel(unique(tD(:,1)))
   tD.Properties.RowNames = tD{:, 1}; 
end

function x = conv_header(x)
% take first token
x = strtok(x, ' .;,');
% if only number, add 'm'
if ~isempty(str2num(x))
    x = ['m' x];
end