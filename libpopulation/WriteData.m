function WriteData(fpath, cHeader, data, bAppend)

if ~is_arg('bAppend'), bAppend = false; end;

if ~isempty(cHeader)
    assert(size(data,2) == length(cHeader), 'data size does not match to header');
end

if exist(fpath,'file') & bAppend
    print_header = 0;
else
    print_header = 1;
end

% found bug 10/5/2016. if header is not provided, data is just appended.
if ~bAppend && exist(fpath,'file')
    delete(fpath);
end

% create folder if necessary
fdir = fileparts(fpath);
if ~isdir(fdir), mkdir(fdir); end

% print header
if print_header && ~isempty(cHeader)
    if bAppend, fid = fopen(fpath, 'a');
    else,       fid = fopen(fpath, 'w');
    end

    buff = sprintf('%s\t', cHeader{:});
    buff = buff(1:end-1);
    fprintf(fid, buff); fprintf(fid, '\r\n');
    fclose(fid);
end

% write data
dlmwrite(fpath, data, 'delimiter','\t', '-append'); % ,'precision','%.5f',

return;