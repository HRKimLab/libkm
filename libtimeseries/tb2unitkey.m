function cUK = tb2unitkey(tb)
% convert table cell array to unitkey cell array
% e.g., the results can be used to choose neurons that have all experiments
% 2019 HRK
cUK = cell(size(tb));
% iterate rows
for iR = 1:size(tb,1)
    % iterate columns
    for iC = 1:size(tb, 2)
        if isempty(tb{iR, iC}) || ismember(tb{iR, iC}(1), {'%','-'}) , continue; end
        try
            cUK{iR, iC} = str2unitkey(tb{iR, iC});
            fprintf(1, 'assigned psth for tb(%d, %d): %s\n', iR, iC, tb{iR, iC})
        catch
            fprintf(1, 'error while assigning psth for tb(%d, %d): %s\n', iR, iC, tb{iR, iC})
        end
    end
end