function print_n_info(b_valid, mids)
% PRINT_N_INFO print out N information for each subject
%
% 2020 HRK

% both b_valid and mids are columns vectors of the same size
assert(size(b_valid, 1) > 1 && size(b_valid, 2) == 1, 'b_valid should be a column vector');
assert(size(mids, 1) > 1 && size(mids, 2) == 1, 'b_valid should be a column vector');
% do a strict type check since to avoid any misbehaviors - n is super critical
assert(size(b_valid, 1) == size(mids, 1) && islogical(b_valid) && isnumeric(mids), ...
    'size of b_valid should match mids. b_valid should be logical, and mids should be numeric');

[nN, gname] = grpstats(b_valid, mids, {@sum, 'gname'});

nTot = sum(nN);

fprintf(1, ' n = %d; ', nTot);
% iterate subjects
for iS = 1:numel(nN)
    fprintf(1, '%d (m%s) ', nN(iS), gname{iS});
    if iS < numel(nN)
        fprintf(1, '+ ');
    end
end
fprintf(1, '\n');

return