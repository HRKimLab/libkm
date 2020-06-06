function x = normailze_by_grp(x, grp, varargin)
% normalize for each group
% 2020 HRK

method = 'zscore'
grp_lim = 20;

process_varargin(varargin);

assert(size(x, 1) == size(grp, 1), 'x and grp should have the same column vector');

% get unique group id
[cmap nColor grp_idx gname gnumel] = grp2coloridx(grp, grp_lim);

for iG = 1:gnumel
    bVG = grp_idx == iG;
    switch(method)
        case 'zscore'
            x(bVG) = zscore(x(bVG));
        case 'subtract_mean'
            x(bVG) = x(bVG) - nanmean(x(bVG));
        otherwise
            error('Unknown method: %s', method);
    end
end