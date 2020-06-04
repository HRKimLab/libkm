function nF = nfields(st)

assert(isstruct(st), 'st should be struct');
fns = fieldnames(st);
nF = numel(fns);