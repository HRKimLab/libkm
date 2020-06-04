function plot_matrix09(x, y,grp, xnames,ynames, xl, yl)

if ~is_arg('y'), y=x; end;
if ~is_arg('xnames'), xnames=[]; end;
if ~is_arg('ynames'), ynames = xnames; end;

[h ax bigax] = gplotmatrix(x, [],grp,[],[],[],'on','hist', xnames,ynames);
% set x and y axes scale
%set(ax(:),'xlim',[-1 1]);
%tmp=ax(1:end-1,:); tmp=tmp(:); bV = ~ismember(tmp,diag(ax));
%set(tmp(bV),'ylim',[-1 1])
% linkaxes(diag(ax),'y');

% correlatin and N
[r p N] = corrN(x, y, 'type','Spearman','rows','pairwise');
if all(all(N(1) == N)), bAllSameN = 1;
else, bAllSameN = 0; end;

% show r, p, and N in the title of each plot
for i=1:size(N,1)
    for j=1:size(N,2)
        if i==j
%            set(ax(i,j),'visible','off'); 
            axes(ax(end,j)); hold on; title(sprintf('N=%d', N(i,j))); hold off;
            axis square;
            set(ax(end,j),'visible','on','ytickmode','auto','yticklabelmode','auto');
        else
            axes(ax(i,j)); %hold on; title(sprintf('N=%d, r=%.2f(p=%.2f)', N(i,j),r(i,j),p(i,j))); hold off;
            %hL=legend(sprintf('N=%d,r=%.2f(p=%.2f)', N(i,j),r(i,j),p(i,j))); legend boxoff;
            %hL=legend(sprintf('%d, %.2f(%.2f)', N(i,j),r(i,j),p(i,j))); legend boxoff;
            if is_arg('xl'), xlim(xl); end;
            if is_arg('yl'), ylim(yl); end;
            xl=xlim; yl=ylim;
            if bAllSameN, hL=text(xl(1),yl(2)*0.85, ['    ' sprintf('%.2f(%.2f)', r(i,j),p(i,j))]);
            else, hL=text(xl(1),yl(2)*0.85, ['  ' sprintf('%d, %.2f(%.2f)', N(i,j),r(i,j),p(i,j))]); end;
            set(hL,'fontsize',9);
            axis square;
            draw_refs(true);
        end
    end
end