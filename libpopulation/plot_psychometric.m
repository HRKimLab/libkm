function [n, center, hB] = plot_outcome_grp(x, grp, edges, x_ref, plot_type)
% plot histogram with significance
if ~is_arg('plot_type'), plot_type = 'bar'; end;

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
if length(grp) == 1
    grp_label = evalin('base', ['pcd_colname{' num2str(grp) '}']); 
    grp= evalin('caller', ['aPD(:,' num2str(grp) ');']);
end
if size(x,2) > 1
    [x grp]= cols2grp(x, grp);
end
    
x=x(:); [grpid gname] = grp2idx(grp);
% plot histogram with significance based on edges
bV = ~isnan(x) & ~isnan(grpid);
x = x(bV);
grp = grp(bV);
grpid = grpid(bV);

if length(gname) == 1
    warning('Only one group found'); 
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

gname = cellfun(@str2num, gname)';
hB = plot(gname, gmean, '-o');
% hold on; 
% errorbar(1:length(gname), gmean, gsem);
% hold off;
% set(gca, 'xtick', gname, 'xticklabel', gname, 'ylim', [0 1]);

n = gmean;
center = gname;

return;