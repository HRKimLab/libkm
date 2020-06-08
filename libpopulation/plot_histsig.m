function [n, center, median_x, p] = plot_histsig(x, is_sig, edges, x_ref, bar_color)
% plot histogram with significance
% caution: NaN < any number is 0. so, if NaN filtering is only based on
% the second parameter as a form of p_values < 0.05, then these values
% won't be NaN at al, thus cannot filter out anything.

% shit. diff -1:.1:1 gives not equal space. floating point bug..
%assert(length(unique(diff(edges)))== 1, 'edge should be equi-linearly spaced');
if length(x) == 1
    try
    x_label = evalin('caller', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('caller', ['aPD(:,' num2str(x) ');']);
    catch
        
    end    
elseif ~isempty(inputname(1))
    x_label = inputname(1);
end

if ~is_arg('is_sig'), is_sig = ~isnan(x); end;
if ~is_arg('bar_color'), bar_color = [0 0 0]; end;

x=x(:); is_sig = is_sig(:);
% plot histogram with significance based on edges
bV = ~isnan(x) & ~isnan(is_sig);
x = x(bV);
is_sig = is_sig(bV);

% fill data
data = NaN(length(x),2);
data(1:nnz(~is_sig),1)= x(~is_sig);
data(1:nnz(is_sig),2)= x(is_sig);

nNS = nnz(~is_sig);
nSig = nnz(is_sig);
assert( (nNS + nSig) == length(x) );

if ~is_arg('edges')
    [n center] = hist(data);
    hB = bar(center, n, 'stacked');
    nOL = 0;
else
    % check upper boundary
    bUB = data == edges(end);
    if nnz(bUB) > 0
        warning('%d data points match with the upper boundary of edages (%.2f). Adjust these data by eps to include them in the rightmost bin', nnz(bUB), edges(end) );
        data(bUB) = data(bUB) - eps;
    end

    % calculate center
    center = edges + diff(edges(1:2))/2;
    center = center(:);
    % counting insignficant and significant elements
    n = histc(data, [edges(:)]);
    % plot histogram
    hB = bar(center, n, 'stacked');
    
    % add 
    xlim([min(edges), max(edges+diff(edges(1:2))/2)])
    % outlier
    nOL = nnz(x<edges(1) |  x>edges(end));
end

% make it grayscale
% don't use this method. this changes colormap of the whole figure
% cmap = [1 1 1; .2 .2 .2];
% set( get(get(hB(1),'Parent'),'Parent'),'colormap' , cmap);

set(hB,'barwidth', 0.8);
tmp=get(hB,'children');
% tmp is not cell if only one kind
if iscell(tmp)
    set(tmp{1},'facecolor', [1 1 1], 'edgecolor', bar_color, 'linewidth', 1.2); 
    set(tmp{2},'facecolor', bar_color, 'edgecolor', bar_color, 'linewidth', 1.2);
else
    set(tmp,'facecolor', bar_color, 'edgecolor', bar_color, 'linewidth', 1.2);
end

% compute mean
median_x = nanmedian(x);

if exist('x_ref','var') && ~isempty(x_ref) && nnz(~isnan(x))
    p = signrank(x-x_ref);
else
    p=NaN;
end

% mark median
hold on; 
yl = get(gca,'ylim');
hM = plot(median_x, yl(2) * 1.1,'v','markeredgecolor','black','markersize', 6, 'linewidth', 1);
if p < 0.05
    set(hM, 'markerfacecolor','black');
end
set(hM, 'tag','median');
hold off;
if exist('x_ref','var') && ~isempty(x_ref)
    sL = line([x_ref x_ref], [min([yl(1) -10000]) max([yl(2) 10000])],'color','k','linestyle','--');
    set(sL, 'tag', 'ref');
    ylim([yl(1) yl(2) * 1.2]);
end
if nOL == 0
    title(sprintf('N=%d, v=%.2f', nnz(bV), median_x));
else
    title(sprintf('N=%d (OL=%d), v=%.2f', nnz(bV)-nOL, nOL, median_x));
end

if ~isnan(p), atitle(sprintf('(p=%s)',p2s(p))); end;
if nNS ~= 0, legend(['NS, N=' num2str(nNS)],['Sig, N=' num2str(nSig)]); end;

if exist('x_label','var'), xlabel(regexprep(x_label,'_',' ')); end;
ylabel('# of cases');