function new_st = filter_psth_by_n(st, varargin)
% filter psth structure by unitkey, regular expression, or  explicit list
% explicit list should be the first argument.
% 5/20/2018 HRK

verbose = 1;
n_grp = NaN;

lo_varargin = process_varargin(varargin);
% sort PSTHs
[flist cPSTH] = sort_psth_structs(st);

bV = true(size(flist));

% filter by group number
if ~isnan(n_grp)
    for iF = 1:numel(bV)
       bV(iF) = bV(iF) & size(cPSTH{iF}.mean, 1) == n_grp; 
    end
end
flist = flist(bV); 
cPSTH = cPSTH(bV);

fprintf(1, 'filter in %d out of %d psths\n', nnz(bV), numel(bV));

% assign it to new structure
new_st = struct();
for iF = 1:length(flist)
   new_st.(flist{iF}) = cPSTH{iF}; 
end