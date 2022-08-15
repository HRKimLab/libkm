function [ax_raster ax_psth] = generate_axis(parent_panel, split_v)
% GENERATE_AXIS generate two vertical axis for raster and psth
% separated from plot_timecourse, 2020 HRK

if numel(split_v) == 1  % split_v is just one value (faction of height of raster)
    assert(split_v <= 1);
    split_v(2) = 1 - split_v;
end
assert((numel(split_v) == 2 )); %% && sum(split_v) == 1)); cmtted out for outside legend

% if parent_panel is two axis object, plots will be added to them.
if numel(parent_panel) == 2 && all(ishandle(parent_panel))
    assert(strcmp(get(parent_panel(1),'type'), 'axes'), 'two parent_panel elements should be axis to be added');
    ax_raster = parent_panel(1);
    ax_psth = parent_panel(2);
    set([ax_raster ax_psth], 'next','add');
    return;
end

% parent panel is designated
if ~isempty(parent_panel) && ismember(class(parent_panel), {'panel'});
    % if axis already exist, clear and reuse them
    if numel(parent_panel.de) > 0 && numel(parent_panel.de.axis) == 2
        ax_raster = parent_panel.de.axis(1);
        ax_psth = parent_panel.de.axis(2);
        % clear the axis
        cla(ax_raster);
        cla(ax_psth);
        return;
    end
    
    p = parent_panel;
    p.pack('h', {8.3/10 []});
    p(1).pack('v', {split_v(1) split_v(2)});
    ax_psth = p(1,2).select();
    ax_raster = p(1,1).select();
    p.ch.margin = 1;
    return;
end

% figure is generated using setpanel(), and parent_panel is not Matlab axes
if ( strcmp(class(get(gcf,'UserData')), 'panel') || ...
        strcmp(class(get(gcf,'UserData')), 'panel_ext') ) && ...
        ~( (~isempty(parent_panel) && ishandle(parent_panel)) && strcmp(get(parent_panel,'type'),'axes'))
    p = get(gcf,'UserData');
    p.pack('h', {8.3/10 []});
    p(1).pack('v', {split_v(1) split_v(2)});
    ax_psth = p(1,2).select();
    ax_raster = p(1,1).select();
    p.ch.margin = 1;
    return;
end

% conventional Matlab figure axes
if ~isempty(parent_panel)
    ax_psth = parent_panel;
else
    ax_psth = gca;
end
% get parent fig. I should create axes on the figure
parent_fig = get(ax_psth, 'parent');

% get axis for raster and psth
pAx = get(ax_psth, 'position');
% push down raster
set(ax_psth, 'position', [pAx(1), pAx(2), pAx(3) * 0.92, pAx(4) * 0.24]);
% axes for raster
ax_raster = axes('position', [pAx(1), pAx(2) + pAx(4) * 0.25, pAx(3) * 0.92, pAx(4) * 0.7], ...
    'parent', parent_fig);

return;