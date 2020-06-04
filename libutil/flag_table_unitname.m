function bV = flag_table_unitnamme(tb, varname, datanames)
% flag table for boolean operations
% 2020 HRK
unitnames = tb{:, varname};
nF = numel(unitnames);
bV = false(nF, 1);

for iF = 1:nF
    iMatches = regexp(unitnames{iF}, datanames);
    bV(iF) = ~all(cellfun(@isempty, iMatches)) ;
end
