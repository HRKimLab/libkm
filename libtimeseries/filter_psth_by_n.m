function [st_filter_in] = filter_psth_by_n(st, varargin)
% filter psth structure by simple numbers
% n_grp: number of groups
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
        if isfield(cPSTH{iF}, 'mean')
            bV(iF) = bV(iF) & size(cPSTH{iF}.mean, 1) == n_grp; 
        else
            bV(iF) = false;
        end
    end
end
flist = flist(bV); 
cPSTH = cPSTH(bV);

fprintf(1, 'filter in %d out of %d psths\n', nnz(bV), numel(bV));

% assign it to new structure
st_filter_in = struct();
for iF = 1:length(flist)
   st_filter_in.(flist{iF}) = cPSTH{iF}; 
end