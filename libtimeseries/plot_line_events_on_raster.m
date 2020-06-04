function hL = plot_line_events_on_raster(ax_raster, event, trigger, grp, event_header)

% keep this same as the ones in plot_events_on_psth()
marker_list = {'rx','gx','mx','cx','yx','kx','r+','g+','m+','c+','y+','k+','rv','gv','mv','cv','yv','kv'};
color_list = {'r','g','m','c','y','k','r','g','m','c','y','k','r','g','m','c','y','k'};

% extract event
e = event(:, event_header);
nE = size(e, 2);
nG = size(e, 1);
hL = [];

% assume that it's grp_idx
y_start  = 0.5; y_end = 0.5;
for iG = 1:nG
    y_end = y_end + nnz(grp == iG);
    for iE = 1:nE
        sE = e{iG, iE};
        tmp = line([sE sE], [y_start y_end], 'color', color_list{iE}, 'parent', ax_raster);
        hL = [hL tmp];
    end
    y_start = y_end;
end