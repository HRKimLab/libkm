function [cD tD cTag tTag] = load_tabular_dataset_info(fpath, varargin)
% LOAD_TABULAR_DATASET_INFO load tabular dataset information from a .tsv file
% load_tabular_dataset_info(fpath, varargin)
%   fpath:          file path of a tab-separated file (.tsv).
%   below are more options.
%   delim:          define delimiter (default is tab, '\t').
%   num_skip_lines: # of lines to be skipped (lines before header).
%   num_header:     # of line to ignore after header.
% 
%
% The target TSV file is a table [# of data tags * # of animals].
% Session numbers do not usually reflect specific protocol because 1) you try out 
% different things 2) training often takes different amount of time. 
% Therefore, for population ananlysis, you need to know which datasets are 
% from a specific protocol. Also, often you run the same protocol over multiple days, 
% and you want to analyze them separately. here, 'data tag' is a string that 
% refers to a subset of your data. (e.g., VR_DAY1: VR open loop, training day 1).
% You organize this info into a table using a spreadsheet program 
% (e.g., google sheet), save it to .tsv file. Once the table info is loaded, 
% use get_datanames()  to retrieve datanames or unitnames of one protocol 
% or protocols or your interest.
%
% Check out 'example_dataset_table (single batch)' and 
% 'example_dataset_table (multiple_batches)' in the google drive to see
% the detailed format of the data table. You click 'File->download->.tsv file.
% Save the .tsv file in your protocol_specific folder.
% 
% Here are some rules in writing data table:
%  - Do not use space (' ') in data tag. Use '_'.
%  - First column of the table is data tag name (anything after ', %?' is ignored)
%  - For header, use numbers (mid) only. Do not put 'm'.
%  - If the first columns of a row starts with '%', the entire row is not loaded.
%  - If the first row of a column starts with '%', the entire column is not loaded.
%    Use the above methods to leave some lengthy comments about datasets
%    e.g., [% below datasets are from second batch, revision 1]
%  - You can put comments after dataname by putting '%'. Please use this to
%    note some details about the dataset. You will forget things later.
%      e.g., [m29s4r1 %animal didn't work well]
% 
% 
% RETURN VALUES:
% cD:   cell array of strings representing the 2D table.
% tD:   table variable representing the same 2D table.
% cTag: cell array of data tags
% tTag: table of data tags
%
% Examples:
% tD = load_tabular_dataset_info ( ...
%  [Y:\NeuRLab\DARamping\DARamping_20200429.tsv'], 'debug', 1);
% data_tags = get_datanames(tD);            % retrieve all data tags
% all_dataname = get_datanames(tD,'all');   % retrieve all datanames
% get_datanames(tD, 'VR_D1')             % retreive datanames in VR_D1 tag.
%
% See also LoadPopulationData5Key, get_datanames, get_datanames_col
%
% 2018 HRK Nawoon

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
    [cD{iR,1} tmp] = strtok(cD{iR,1}, ', %?');
end

% identify data tag and create cell array for tag
% Nawoon

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