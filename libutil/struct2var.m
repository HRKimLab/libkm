function struct2var(st)
% assign fields of a strucure as variables
% see var2struct for the opposite operation
% 1/27/2017 HRK
if isempty(st)
    warning('struct2var: empty');
    return;
end
for fn = fieldnames(st)'
    assignin('caller', fn{1}, st.(fn{1}) );
end
