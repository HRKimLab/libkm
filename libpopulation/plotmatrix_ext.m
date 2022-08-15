function plotmatrix_ext(x, y, grp, xnames,ynames, xl, yl)
% PLOTMATRIX_EXT an extension version of plotmatrix
% 2019 HRK

if ~is_arg('y')
    xy_same = 1;
    y=x; 
else
    xy_same = 0;
end
if ~is_arg('xnames'), xnames=[]; end;
if ~is_arg('ynames'), ynames = xnames; end;

% call gplotmatrix
[h ax bigax] = gplotmatrix(x, y,grp,[],[],[],'on','hist', xnames,ynames);

% compute correlatin based on combinations of x and y
[r p N] = corrN(x, y, 'type','Spearman','rows','pairwise');
if all(all(N(1) == N)), bAllSameN = 1;
else, bAllSameN = 0; end;

% show r, p, and N in as an annotation of each plot
for i=1:size(N,1)
    for j=1:size(N,2)
        if 0 % do not use this for nowi==j && xy_same == 1
            axes(ax(end,j)); hold on; title(sprintf('N=%d', N(i,j))); hold off;
            axis square;
            set(ax(end,j),'visible','on','ytickmode','auto','yticklabelmode','auto');
        else
            axes(ax(j, i)); %hold on; title(sprintf('N=%d, r=%.2f(p=%.2f)', N(i,j),r(i,j),p(i,j))); hold off;
            
            if is_arg('xl'), xlim(xl); end;
            if is_arg('yl'), ylim(yl); end;
            cur_xl = xlim(); cur_yl = ylim();
            
            % show numbers on the plot
            if bAllSameN
                hL=text(cur_xl(1), cur_yl(2)*0.85, ['    ' sprintf('%.2f(%.2f)', r(i,j),p(i,j))]);
            else
                hL=text(cur_xl(1), cur_yl(2)*0.85, ['  ' sprintf('%d, %.2f(%.2f)', N(i,j),r(i,j),p(i,j))]); 
            end
            set(hL,'fontsize',9);
            
%             axis square;
        end
    end
end