function remove_labels()
ax = findobj(gcf, 'type','axes');
% set(ax, 'xticklabel',[], 'yticklabel', []);
for iA=1:length(ax)
    switch(get(ax(iA),'tag'))
        case {'legend', 'Colorbar'}
            continue;
    end
    xlabel(ax(iA), '');
    ylabel(ax(iA), '');
    
    % reduce # of ticks if the size of axes is small
    pos = get(ax(iA), 'position');
    if pos(3) < 0.1
        t = get(ax(iA),'xtick');
        set(ax(iA),'xtick', [t(1) t(end)],'xticklabelmode','auto');
    end
    if pos(4) < 0.1
        t = get(ax(iA),'ytick');
        set(ax(iA),'ytick', [t(1) t(end)],'yticklabelmode','auto');
    end
    
    % only leave N and remove other titles
    hT = get(ax(iA), 'Title');
    sT = get(hT, 'string');
    iN = [findstr(sT,'N=') findstr(sT,'N =') findstr(sT,'n=') findstr(sT,'n =')];
    tok = strtok(sT(iN:end));
     title(ax(iA), tok);
end