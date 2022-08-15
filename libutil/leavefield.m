function s = leavefield(s, field)
% leave fieldnames of a struct variable (opposite of rmfield)
% 2022 HRK

fnames = fieldnames(s);
% determine field names to remove
fnames_to_remove = setdiff(fnames, field);
s = rmfield(s, fnames_to_remove);