function [n, center, median_x, pDiff, pMedian, hB] = plot_histgrp(x, grp, edges, x_ref, varargin)
% plot histogram with group
% 2012 HRK

type = 'bar';

process_varargin(varargin);

% shit. diff -1:.1:1 gives not equal space. floating point bug..
%assert(length(unique(diff(edges)))== 1, 'edge should be equi-linearly spaced');
if length(x) == 1 && ~isnan(x)
    x_label = evalin('base', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('caller', ['aPD(:,' num2str(x) ');']);
elseif ~isempty(inputname(1))
    x_label = inputname(1);
end
if isempty(grp)
    grp = ones(size(x));
end
if length(grp) == 1 && ~isnan(grp)
    try
        grp_label = evalin('base', ['pcd_colname{' num2str(grp) '}']); 
        grp = evalin('caller', ['aPD(:,' num2str(grp) ');']);
    catch
%         disp('hoho');
    end
end
if size(x,2) > 1
    [x grp]= cols2grp(x, grp);
end

if isempty(x)
    n=NaN, center=NaN, median_x=NaN, pDiff=NaN, pMedian=NaN, hB=[]
    return; 
end

x=x(:); [grpid gname] = grp2idx(grp);
% plot histogram with significance based on edges
bV = ~isnan(x) & ~isnan(grpid);
x = x(bV);
grp = grp(bV);
grpid = grpid(bV);

if length(gname) == 1
%     warning('Only one group found'); 
end;

% basic statistical analysis
% CAUTION: all stats includes outliers!
% calculate medians for each group
gmedian = grpstats(x, grp, 'median');
gnumel = grpstats(x, grp, 'numel');
median_x = gmedian;
% compute total mean
tot_median = nanmedian(x);
% appand it to the end
median_x(end+1) = tot_median;

[pDiff bNonEqualVar] = test_same_dist(x, grp);

% use signed rank test to see if median is sig. different from ref.
if is_arg('x_ref') && nnz(~isnan(x)) > 0
    pMedian = signrank(x-x_ref);
else
    pMedian=NaN;
end

% fill data
data = NaN(length(x), length(gname));
for iG=1:length(gname)
    bG = grpid == iG;
    data(1:nnz(bG),iG)= x(bG);
    
    % do signed rank test for each group
    if is_arg('x_ref')
        if nnum(x(bG)-x_ref) == 0, pMedian(iG+1,1) = NaN;
        else
            pMedian(iG+1,1) = signrank(x(bG)-x_ref);
        end
    end
end
    
if ~is_arg('edges')
    [n center] = hist(data);
    % plot to get xl
    hist(data);
    xl = xlim;
else
    % check upper boundary
    bUB = data == edges(end);
    if nnz(bUB) > 0
        warning('%d match with the upper boundary of edages. to avoid missing them in the plot, data will be reduce by eps', nnz(bUB) );
        data(bUB) = data(bUB) - eps;
    end
    
    % calculate center
    center = edges + diff(edges(1:2))/2;
    center = center(:);
    % counting insignficant and significant elements
    n = histc(data, [edges(:)]);
    xl = [min(edges), max(edges+diff(edges(1:2))/2)];
end

switch(type)
    case 'bar'
        % plot histogram
        hB = bar(center, n, 'grouped');
    case 'pdf'
        hB = plot(center,  n ./ repmat( sum(n) , [size(n, 1) 1]) );
end

set(gca, 'xlim', xl);
% outlier
nOL = nnz(x<xl(1) |  x>xl(2));

% transpose if output is column vector
if size(n,1) == 1, n = n'; end
if size(center,1) == 1, center = center'; end

% add markers for total median, group medians
hold on; 
yl = get(gca,'ylim');
hV = plot(tot_median, yl(2)*1.1,'v','color','k'); set(hV, 'tag','median');
if is_arg('x_ref') && pMedian(1) < .05, set(hV, 'markerfacecolor','black'); end;
cm = colormap; 
clm = caxis;   % kludge to match color. I cannot directly get color from bar plot!
cL={};
for iG=1:length(gmedian)
    switch(type)
    case 'bar',  
        % works in matlab before graphics change (2014b)
        if matlab_ver() < 8.4 
            idx_color = fix((iG-clm(1))/(clm(2)-clm(1))*(size(cm,1)-1))+1;
            sym_color = cm(idx_color,:);
        else
%             sym_color = hB(1).FaceColor;
            sym_color = hB(iG).FaceColor;  % 10/7/2019 HRK
        end
    case 'pdf', idx_color = iG;
    end
    hV = plot(gmedian(iG), yl(2)*1.03, 'v','color', sym_color,'linewidth',1); 
    set(hV, 'tag','median');
    if is_arg('x_ref') && pMedian(iG+1) < .05, set(hV, 'markerfacecolor', sym_color); end;
    cL{iG} = [gname{iG} ', N=' num2str(gnumel(iG))];
end
hold off;
% draw reference line
if is_arg('x_ref')
    hRef = draw_refs(0, x_ref);
    set(hRef,'color','k','linestyle',':','tag','ref');
end
% legend and title
hL=legend(cL);    % ,'location','best' I believe matlab can do decently to avoid simple historgram...NO
set(hL,'fontsize',9); % 'box','off'); it could be better to move box later by hand..
if nOL == 0
    title(sprintf('N=%d ',nnz(bV)));
else
    title(sprintf('N=%d (OL=%d)',nnz(bV)-nOL, nOL));
end
if ~isnan(pMedian), atitle(sprintf('v=%.2f(p=%s)', tot_median, p2s(pMedian(1))));
elseif numel(gnumel) == 1, atitle(sprintf('v=%.2f', tot_median)); end;
if ~isnan(pDiff) && length(gname) == 2 && ~bNonEqualVar atitle(sprintf(' M.W.U (p=%.2f)', pDiff));
elseif ~isnan(pDiff) && length(gname) == 2 && bNonEqualVar atitle(sprintf(' K.S.(p=%.2f)', pDiff));
elseif ~isnan(pDiff), atitle(sprintf(' K.W. (p=%.2f)', pDiff));
end;
ylabel('# of cases');
yl = ylim;
if yl(2) <= 5, ytick(0:1:ceil(yl(2))); end; % avoid ticking .5