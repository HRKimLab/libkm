function struct2var(st)
% STRUCT2VAR assign fields of a strucure as variables
% see also SCRIPTVAR2STRUCT, VAR2STRUCT
%
% 1/27/2017 HRK
if isempty(st)
    warning('struct2var: empty');
    return;
end
for fn = fieldnames(st)'
    assignin('caller', fn{1}, st.(fn{1}) );
end
