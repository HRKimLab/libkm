function save_key(filepath, key, data, bAppend)
% save data based on key - data pair. data with the same key will be
% overwritten.
% key: 1 * n array of keys
% data: one entity, either value or struct or cell
% 7/9/2015 HRK

assert(all(~isnan(key)), 'key should not include NaN since the key will be always a new element');
if isempty(data), return; end;
if ~is_arg('bAppend'), bAppend = 0; end;

% generate directory if it does not exist
pathstr = fileparts(filepath);
if ~isdir(pathstr), mkdir(pathstr); end;

% overwrite if not append. don't spend time in loading unless necessary.
if ~bAppend
    key_list = key; data_list = data;
    save(filepath, 'key_list','data_list');
    return
end

% append
if exist(filepath, 'file')
    load(filepath)
    assert( size(key_list, 2) == size(key, 2) )
else
    % empty array with the column size matched with key
    tmp = NaN(1, size(key, 2));
    key_list = tmp([],:); data_list = [];
end

% find key in key_list
bMatch = all(repmat(key, [size(key_list, 1) 1]) == key_list, 2);
iFound = find(bMatch);

% merge fields if new fields are added
for fn = fieldnames(data)'
    if ~isfield(data_list, fn) && ~isempty(data_list)
        data_list(1).(fn{1}) = [];
    end
end

if isempty(iFound)
    key_list = [key_list; key];
%     if isfield(data_list, 'x') && isfield(data_list, 'n_grp') && isfield(data_list, 'pDiff') && ~isfield(data_list, 'numel')
%         data_list(1).numel = [];
%     end
    data_list = [data_list(:); data];
else
%     if isfield(data_list, 'x') && isfield(data_list, 'n_grp') && isfield(data_list, 'pDiff') && ~isfield(data_list, 'numel')
%         data_list(1).numel = [];
%     end
%     
try
    data_list(iFound) = data;
catch
    warning('Dissimilar structure during save_key. just start over !!!');
    data_list = data;
end
end

% save to file
asave(filepath, 'key_list','data_list');