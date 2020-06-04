function st = remove_empty(st)

if isstruct(st)
    cF = fieldnames(st);
    bE = structfun(@isempty, st);
    st = rmfield(st, cF(bE));

elseif iscell(st)
    
    bE = cellfun(@isempty, st);
    if nnz(bE) > 0
        warning('Empty PSTH structure (%d). skip those', nnz(bE));
        st(bE) = [];
    end
    
end