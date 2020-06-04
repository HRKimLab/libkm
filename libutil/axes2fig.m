function new_fid = axes2fig(ax, bKeepRatio)
DEF_SIZE = 3.0; % default size of figure in inch

if ~is_arg('ax')
    ax = gca;  
end
% if ax is number, get axis from the current figure
if isnumeric(ax) && ~ishandle(ax)
    ax_list = findobj(gcf,'type','axes');
    ax = ax_list(end-(ax-1));
end

if ~is_arg('bKeepRatio')
    bKeepRatio = 1;
end
if ischar(ax)
    atag = ax;
    ax = findobj(get(0, 'children'), 'tag', atag);
    if numel(ax) < 1
        error('No axes with tag %s found', atag);
    elseif numel(ax) > 1
        error('More than one axes with tag %s found', atag);
    end
end
fid = gcf;
new_fid = figure;
figure(fid);
ax_pos = get(ax, 'position');
ratio = ax_pos(4)/ax_pos(3);
copyobj(ax, new_fid);
figure(new_fid);
set(gca, 'tag', '');
if bKeepRatio
    if ratio > 1.3 
        set(gca,'position', [.17 .13 .66 .74]);
    elseif ratio < 0.8
        set(gca,'position', [.13 .17 .74 .66]);
    else
        % standard axes margin
        set(gca,'position', [.15 .15 .7 .7]);
    end
    set(new_fid, 'position', [100 100 400 400*ratio]);
    set(new_fid, 'papersize', [DEF_SIZE DEF_SIZE*ratio], 'paperposition', [0 0 DEF_SIZE DEF_SIZE*ratio], 'PaperUnits', 'inches');
    set(gca,'ytickmode','auto','yticklabelmode','auto');
else
    set(gca,'position', [.15 .15 .7 .7]);
    set(new_fid, 'position', [100 100 400 400]);
    set(new_fid, 'papersize', [DEF_SIZE DEF_SIZE], 'paperposition', [0 0 DEF_SIZE DEF_SIZE], 'PaperUnits', 'inches');
    set(gca,'ytickmode','auto','yticklabelmode','auto');
    resizefig;
end

formatfig([], new_fid);