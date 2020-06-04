function psths = cell2psths(cPSTH, cName, varargin)
% convert cell array of psth to structure of psths
% if cPSTH is 2D table, output will lose the structure
% and the position of entity will not be preserved.
% 2020 HRK

process_varargin(varargin);

assert(all(size(cPSTH) == size(cName) ), 'size of cPSTH and cName should match');
% empty entities in cell array should matche with the empty entities in names
bPSTH = cellfun(@isempty, cPSTH);
bName = cellfun(@isempty, cName);
assert(all(all(bPSTH == bName)), 'valid entities in cPSTH and cName should match');
% make structured psths
psths = struct();
for iR = 1:size(cPSTH, 1)
    for iC = 1:size(cPSTH, 2)
        if isempty(cPSTH{iR, iC})
            continue;
        end
        if isempty(cName{iR, iC})
            warning('name is empty for (%d, %d). psths will not be assigned', iR, iC);
            continue;
        end
        if isfield(psths, cName{iR, iC})
            error('cell2psths: redundant name (%s) found', cName{iR, iC});
        end
        
        psths.(cName{iR, iC}) = cPSTH{iR, iC};
    end
end
