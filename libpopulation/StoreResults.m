function StoreResults(fdir, fname, file_tag, unitkey, cHeader, data)
% StoreResults(fdir, fname, file_tag, unitkey, cHeader, data)
%  advanced version of WriteData. this function attempts to store data in a flexible way, 
% considering later distributed analysis situation (e.i., running analysis in multiple
%  machine). In that case, store results can be thoughts as sending
%  'message', and this function can select multiple way to store those
%  data. data is usually consists of (unitkey, array of values).
% 
% gSave.type = 0, or undefined: use whichever suggested by fdir. 
%    if fdir is full path, then append to the destination file
%    if fpth is directory, then store as to 'unitkey.tag' file. This is
%      usuful when we want to run analysis code from multiple computer. we
%      can avoid messing up the accumulated file.
% gSave.type == 1 : force to append to [fname]. error if fdir is directory
% gSave.type == 2 : force to save to individual file. use path part of fpath if it has filename at the end.
% gSave.type == 3 : foree to save to [fname_m'host_id'].
STORE_UNDEF = 0;
ONE_FILE = 1;
KEY_FILES = 2;
PER_HOST = 3;

global gSave
if ~is_arg('gSave') || ~isfield(gSave,'type'), store_type = STORE_UNDEF; 
else, store_type = gSave.type; end;

% if store_type=0, set it to 1 if it has fname, otherwise 2.
if store_type == STORE_UNDEF 
    if ~isempty(fname), store_type = ONE_FILE; 
    else,               store_type = KEY_FILES;
    end
end

% add CELL when forgotten
if store_type == ONE_FILE && ~strcmp(cHeader{1},'CELL')
%     warning('First column should be CELL. add for now');
    cHeader = {'CELL', cHeader{:}};
end

% compare header size and data size 
bSaveUnitKey = false;
if ~isempty(cHeader) && strcmp(cHeader{1},'CELL')
    bSaveUnitKey = true;
    assert(size(data,2) == (length(cHeader)-1), 'data size does not match to header');
elseif ~isempty(cHeader)
    assert(size(data,2) == length(cHeader), 'data size does not match to header');
end

if ~isdir(fdir)
    mkdir(fdir);
end

% set filename and open mode accordingly
switch (store_type)
    case ONE_FILE
        fpath = fullfile(fdir, fname); fopen_option = 'a';
    case KEY_FILES  
        fpath = fullfile(fdir, [unitkey '.' file_tag]); fopen_option = 'w';
    case PER_HOST
        [tmp file_name file_ext tmp] = fileparts(fname);
        fpath = fullfile(fdir, [file_name '_m' num2str(gSave.host_id) file_ext]); fopen_option = 'a';
end

% write header if this is first time to write, or it is KEY_FILES
if ~isempty(cHeader) && (~exist(fpath,'file') || store_type == KEY_FILES)
    print_header = true;
else
    print_header = false;
end

% open file and write data
switch store_type
    case {ONE_FILE, KEY_FILES, PER_HOST}
        % for performance, do not open file unless necessary
        if print_header || bSaveUnitKey
            fid = fopen(fpath, fopen_option);
        end
        % print header
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
    otherwise
end

% write data
dlmwrite(fpath, data, 'delimiter','\t', '-append'); % ,'precision','%.5f',

return;