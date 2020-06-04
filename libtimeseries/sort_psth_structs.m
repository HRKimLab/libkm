function [sorted_names cPSTH sorted_stPSTHs] = sort_psth_structs(stPSTHs, name_format)
% sort cell array of string format of unitkeys, or structure
% name_format: 'unitkey5', 'no_sort'
sorted_names  = [];
cPSTH = {};
if ~is_arg('name_format'), name_format = 'unitkey5'; end;

cUnitname = fieldnames(stPSTHs);

% extract numeric ids
switch(name_format)
    case 'unitkey5'
        cKeys = cellfun( @str2unitkey5, cUnitname, 'un', false);
        keys = cat(1, cKeys{:});
    case 'no_sort'
        keys = (1:numel(cUnitname))';
    otherwise
        error('Unknown name format: %s', name_format');
end

% sort numeric array of unitkeys
[sorted_keys, iS] = sortrows(keys);

sorted_names = cUnitname(iS);
% make additional return values only necessary to save time and memory
if nargout == 1, return; end
% re-arrange unit names based on the sorted index
cPSTH = cellfun(@(x) stPSTHs.(x), sorted_names, 'un',false);


if nargout == 2, return; end;
% re-order and make sorted structured psths
for iF = 1:numel(sorted_names)
    sorted_stPSTHs.(sorted_names{iF}) = stPSTHs.(sorted_names{iF});
end