function SaveResults(fpath, unitkey, cHeader, data, bAppend)
% SaveResults(fpath, unitkey, cHeader, data, bAppend)
%   Save results in text format with cell identifier(unitkey).
%
%   fpath: full path of the reult file
%   unitkey: identifier string (e.g., 'm32c213r2') or cell array of them
%   cHeader: cell array of file header
%   data: an array of the size [nUnitkey X nHeader]
%   bAppend: 1 for append and 0 for overwrite
%   See also WriteData, StoreResults
%
%   3/14/2014 HRK


if ~is_arg('bAppend'), bAppend = false; end;

nRow = size(data, 1);
% iterate rows if more data has more than one row
if nRow > 1
    assert(iscell(unitkey), 'unitkey should be cell array if data has more than one row');
    assert( numel(unitkey) == nRow, '# of unitkey (%d) should be same as # of rows (%d) in data', ...
        numel(unitkey), nRow);
    for iR = 1:nRow
        SaveResults(fpath, unitkey{iR}, cHeader, data(iR, :), bAppend);
        % it should append to the file from the second time
        bAppend = 1;
    end
    return;
end

% add CELL when forgotten
if isempty(unitkey)
    bSaveUnitKey = false;
else
    bSaveUnitKey = true;
    if ~strcmp(cHeader{1},'CELL')
    warning('First column should be CELL. add for now');
    cHeader = {'CELL', cHeader{:}};
    end
end

% compare header size and data size 
if ~isempty(cHeader) && strcmp(cHeader{1},'CELL')
    bSaveUnitKey = true;
    assert(size(data,2) == (length(cHeader)-1), 'data size does not match to header');
elseif ~isempty(cHeader)
    assert(size(data,2) == length(cHeader), 'data size does not match to header');
end

% set filename and open mode accordingly
if bAppend, fopen_option = 'a';
else, fopen_option = 'w'; end;

% write header if this is first time to write, or it will be overwritten.
if ~isempty(cHeader) && ~exist(fpath,'file') || bAppend == false
    print_header = true;
else
    print_header = false;
end

% open file and write data
if print_header || bSaveUnitKey
    fid = fopen(fpath, fopen_option);
end
% print header with newline
if print_header
    buff = sprintf('%s\t', cHeader{:});
    buff = buff(1:end-1);
    fprintf(fid, buff); fprintf(fid, '\r\n');
end

% write unitkey if necessary
if bSaveUnitKey
    fprintf(fid, '%s\t', unitkey);
end
if print_header || bSaveUnitKey
    fclose(fid);
end

% write data
dlmwrite(fpath, data, 'delimiter','\t', '-append'); % ,'precision','%.5f',

return;