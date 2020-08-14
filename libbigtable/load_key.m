function data = load_key(filepath, key)
% load data based on key 
% key: m * n array of keys
% data: m * p, either value or struct or cell
% 7/9/2015 HRK

d = load(filepath, '-mat');

assert(size(d.key_list, 2) == size(key, 2), 'column size of key (%d) should be matched to the saved data (%d)', ...
    size(key,2), size(d.key_list,2))

[bMatch locb]= ismember(key, d.key_list, 'rows');

% check unmatched key
if nnz(bMatch) ~= size(key, 1)
    error('# of found items (%d) is different from requested (%d)', nnz(bMatch), size(key, 1));
end

data = d.data_list(locb, :);