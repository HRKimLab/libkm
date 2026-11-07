function [col grp] = cols2grp(varargin)
% COLS2GRP transform data from 2D array format to column vector format.
% [col grp] = cols2grp(x, ids) x is 2D array of [N observations X M groups].
%  sometimes you need to convert it to an unpaired format of a column vector 
%  of N*M elements. 
% 
%
% EXAMPLES:
% x = [1 2; 1.1 2.1; 1.2 2.2];
% [col grp] = cols2grp(x, [10 20]);
%
% % results:
% % col = [1;  1.1; 1.2;  2;  2.1; 2.2];
% % grp = [10; 10;  10;   20; 20;  20];
%
% % paired comparison
% plot_barpair(x);
% 
% % unpaired comparison
% plot_bargrp(col, grp);
% 
% See also PLOT_BARPAIR, PLOT_BARGRP, PLOT_HISTGRP
% 
% HRK 2013

assert(mod(nargin,2) == 0, '# of argument should be even');

for iA = 1:2:nargin
    cols = varargin{iA};
    grpid = varargin{iA+1};
    
    if size(cols,2) > 1 % array
        [this_col this_grp] = cols2grp_Array(cols, grpid);
    else                % row vector
        this_col = cols;
        this_grp = repmat(grpid, size(cols));
        assert(size(this_col, 1) == size(this_grp, 1), '# of col and group deos not match for %dth arg',(iA+1)/2);
    end
    
    if iA == 1  % first element. create variable.
        col = this_col; grp = this_grp;
    else        % append from the second time.
        col = [col; this_col];
        grp = [grp; this_grp];
    end
end

return;

function [col grp] = cols2grp_Array(cols, grpid)
% convert multiple colum vectors into one column with group id column

if ~is_arg('grpid')
    grpid = 1:size(cols,2);
end

assert( size(cols,2) == length(grpid), '# of columns in cols (%d) should be matched to the number of grpid (%d)', size(cols,2), length(grpid));

% grpid should be row vector
grpid = grpid(:)';
col = cols(:);
grp = repmat(grpid, [size(cols,1) 1]);
grp = grp(:);