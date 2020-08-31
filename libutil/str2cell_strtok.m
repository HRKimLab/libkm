function new_header = str2cell_strtok(s)
% STR2CELL_STRTOK convert string to cell using strtok
% 2020 HRK
assert(ischar(s), 's should be string')
new_header = {};
[new_header{1} rem] = strtok(s)
while ~isempty(rem)
    [new_header{end+1} rem] = strtok(rem)
end
s = new_header;
