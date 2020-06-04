function s = rmfield_noerr(s, cFN)
% rmfield without error.
% remove the field only if it exists
% 2019 HRK
if strcmp(class(cFN), 'char')
    cFN = {cFN}; 
end

for iF = 1:length(cFN)
    if isfield(s, cFN{iF})
        s = rmfield(s, cFN{iF});
    end
end
    