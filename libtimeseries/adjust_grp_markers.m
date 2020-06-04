function adjust_grp_markers(ax)
% adjust x position of group markers
% assumes that group markers, both white background line and square group
% markers, have tag name 'grpmark'
% 2018 HRK

if ishandle(ax)
    xl = get(ax, 'xlim');
    
    x_off_line = xl(1) + range(xl) * 0.995;
    x_off_marker = xl(1) + range(xl) * 0.995;

    h = findobj(ax, 'tag','grpmark');
    for iH = 1:numel(h)
        xd = get(h(iH), 'xdata');
        assert( numel(nonnan_unique(xd)) == 1);
        if numel(xd) == 2 % background white line
            set(h(iH), 'xdata', x_off_line * ones(size(xd)));
        else  % markers
            set(h(iH), 'xdata', x_off_marker * ones(size(xd)));
            % put markes to the top of the visual stack
            uistack(h(iH), 'top')
        end
    end
end
