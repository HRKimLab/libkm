function [n, center, hB] = plot_outcome_grp(x, grp, varargin)

x_ref = [];
plot_type = 'bar';
x_type = 'categorical' % categorical or scalar

process_varargin(varargin);

% shit. diff -1:.1:1 gives not equal space. floating point bug..
%assert(length(unique(diff(edges)))== 1, 'edge should be equi-linearly spaced');
if length(x) == 1
    x_label = evalin('base', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('caller', ['aPD(:,' num2str(x) ');']);
elseif ~isempty(inputname(1))
    x_label = inputname(1);
end
if isempty(grp)
    grp = ones(size(x));
end
if isstruct(grp)
    ginfo = grp;
    % in this case, all the internel ordering follows the index of label,
    % which is grp_idx. And the order of grpstat() in compute_avggrp should
    % be matched to the order of label both is in the ascending order.
    grp = ginfo2grp(grp, x);
elseif length(grp) == 1
    grp_label = evalin('base', ['pcd_colname{' num2str(grp) '}']); 
    grp= evalin('caller', ['aPD(:,' num2str(grp) ');']);
end
if size(x,2) > 1
    [x grp]= cols2grp(x, grp);
end
    
x=x(:); [grpid gname] = grp2idx(grp);
unq_grp = cellfun(@str2num, gname);
% plot histogram with significance based on edges
bV = ~isnan(x) & ~isnan(grpid);
x = x(bV);
grp = grp(bV);
grpid = grpid(bV);

if nnz(bV) == 0
    n = NaN; center = NaN; hB = [];
    return;
end

if length(gname) == 1
    disp('plot_outcome_grp: Only one group found'); 
end;

% basic statistical analysis
% CAUTION: all stats includes outliers!
% calculate medians for each group
gmedian = grpstats(x, grp, 'median');
gmean = grpstats(x, grp, 'mean');
gsem = grpstats(x, grp, 'sem');
gnumel = grpstats(x, grp, 'numel');
median_x = gmedian;
% compute total mean
tot_median = nanmedian(x);

switch(x_type)
    case 'categorical'
        switch(plot_type)
            case 'bar'
                hB = bar(1:length(gname), gmean);
            case 'line'
                hB = plot(1:length(gname), gmean, '-o');
        end
        % hold on; 
        % errorbar(1:length(gname), gmean, gsem);
        % hold off;
        set(gca, 'xtick', 1:length(gname), 'xticklabel', gname, 'ylim', [0 1]);
    case 'scalar'
        switch(plot_type)
            case 'bar'
                hB = bar(unq_grp, gmean);
            case 'line'
                hB = plot(unq_grp, gmean, '-o');
        end
end

n = gmean;
center = unq_grp;

return;