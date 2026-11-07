function [s s_removed] = rmfield_noerr(s, cFN)
% RMFIELD_NOERR rmfield without error.
% cFN is a cell array of field names to be removed.
% remove the field only if it exists.
%
% see also rmfield
% 
% 2019 HRK

if strcmp(class(cFN), 'char')
    cFN = {cFN}; 
end
% iterate elements in cFN
for iF = 1:length(cFN)
	% only if s contains the field
    if isfield(s, cFN{iF})
		% save it to s_removed
		if ~isempty(s)
			s_removed.(cFN{iF}) = s.(cFN{iF});
		end
		% remove the field
        s = rmfield(s, cFN{iF});
    end
end
    