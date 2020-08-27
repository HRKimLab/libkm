function [hG ax_grp] = mark_group_on_plot(ax, grp_idx, cmap, mode)
% color code group info on the right side of raster or image array
% 2016 HRK, made separate function 2018
assert(max(grp_idx) <= size(cmap,1) );
ax_pos = get(ax,'position');
parent_fig = get(ax, 'parent');
xl = get(ax,'xlim'); yl = get(ax,'ylim');
if ~is_arg('mode'), mode = 'adddot'; end;
n_trial = size(grp_idx,1);
hG = []; ax_grp = [];

if max(grp_idx) == 1
    return
end
    
% marker size for scatter
if n_trial < 20, marker_size = 24; bg_line_width = 8;
elseif n_trial < 100, marker_size = 22; bg_line_width = 10;
else, marker_size = 20; bg_line_width = 12; end

x_off_line = xl(1) + range(xl) * 0.992;
x_off_marker = xl(1) + range(xl) * 0.997;
x_off_patch = xl(1) + range(xl) * 0.982;

prev_next = get(ax,'nextplot');
switch(mode)
    case 'add'
        set(ax, 'nextplot','add');
        
        % draw background white line
        %         hWB = plot(ax, ones(1,2) * x_off_marker, [-0.5 n_trial+0.5], 'w', 'linewidth', bg_line_width);
        %         set(hWB, 'tag', 'grpmark'); % later used to adjust x position of marker
        
        %         hS1 = scatter(ax, x_off_line * ones(size(grp_idx)), 1:n_trial, marker_size, 'w', 'filled');
        %         set(hS1, 'tag','grpbg');   % later used to adjust x position of marker
        h_bg = patch([x_off_patch xl(2) xl(2) x_off_patch], [yl(2)+1 yl(2)+1 yl(1)-1 yl(1)-1], 'w','parent',ax);
        set(h_bg,'linestyle','none')
        ax_grp = ax;
    case 'inside'

        % inside raster axis
        ax_grp = axes('position', [ax_pos(1)+ax_pos(3)*0.985 ax_pos(2) ax_pos(3)*0.015 ax_pos(4)], ...
            'handlevisibility','off','parent', parent_fig);
        set(ax_grp,'xtick',[],'ytick',[], 'xlim', [x_off_marker-.5 x_off_marker], ...
            'ylim', get(ax, 'ylim'), 'nextplot', 'add', ...
            'ydir', 'reverse', 'xcolor','w','linewidth',0.01, 'handlevisibility','off')
        
    case 'outside'
        % outside raster axis
        ax_grp = axes('position', [ax_pos(1)+ax_pos(3)*1.01 ax_pos(2) ax_pos(3)*0.01 ax_pos(4)], ...
            'handlevisibility','off','parent', parent_fig);        
        set(ax_grp,'xtick',[],'ytick',[], 'xlim', [x_off_marker-.1 x_off_marker+0.1], ...
            'ylim', get(ax, 'ylim'), 'nextplot', 'add', ...
            'ydir', 'reverse','ycolor','w', 'xcolor','w','linewidth',0.01, 'handlevisibility','off')
        
        
    case 'image'
    % image strategy is best, but does not work because matlab uses single
    % colormap for the whole figure..
%     image(grp_idx, 'parent', ax_grp);
%     colormap(ax_grp, cmap);
end

% draw squares for each group
i_trials = 1:n_trial;
for iG = 1:max(grp_idx)
    bV = grp_idx == iG;
    hS2 = scatter(ax_grp, x_off_marker * ones(size(grp_idx(bV))), i_trials(bV), marker_size, cmap(iG,:), 'filled');
    set(hS2, 'marker', 's', 'tag','grpmark');
end
set(ax_grp, 'xlim', xl,'visible','off');

% error when using colormap directly.. draw each group
%         Warning: RGB color data not yet supported in Painter's mode 
%         hS2 = scatter(ax_grp, x_off_marker * ones(size(grp_idx)), 1:n_trial, marker_size, cmap(grp_idx,:), 'filled');
%         set(hS2, 'marker', 's', 'tag','grpmark');

set(ax, 'nextplot', prev_next);
linkaxes([ax ax_grp],'y');