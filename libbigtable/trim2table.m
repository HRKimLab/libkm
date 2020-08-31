function tb = trim2table(C)
% result of textscan() is cell colum vector of cell row vectors.
% convert it to cell array of string % make cell array of cell arrays into matrix of cells
% 2018 RHK

assert(iscell(C) && iscell(C{1}));

% iterate column
nC = numel(C);
for iC = 1:nC
    n_rows(iC) = size(C{iC}, 1);
end

min_rows = min(n_rows);
max_rows = max(n_rows);

if any(abs(n_rows - min_rows) > 1) || any(abs(n_rows - max_rows) > 1)
    error('Diff. in rows > 2. cannot merge in to cell array');
end

for iC = 1:nC
   if n_rows(iC) == max_rows, continue; end;
   
   % now this column is one less element than max_rows
   
   % delete last row of the current column
   C{iC}{end+1} = '';
end
% C{end}{end+1} = C{end}{end};

% make sure that table size is same
if nunique(cellfun(@numel, C))  ~= 1
    warning('# of rows in each column is not same');
    C
    keyboard
end

tb = cat(2, C{:});