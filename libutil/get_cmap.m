function cmap = get_cmap(nColor)
global gP

if isfield(gP, 'cmap') && ~isempty(gP.cmap)
    switch(class(gP.cmap))
        case 'cell'  % different colormap for each group #
            if nColor <= numel(gP.cmap) && ~isempty(gP.cmap{nColor})
                cmap = gP.cmap{nColor};
            else
%                 warning('Cannot find gP.cmap{%d}. use default', nColor);
                cmap = jet(nColor);
            end
            if any(any(cmap > 1))
                    cmap = cmap / 255;
            end
            return;
        case 'double'
            if nColor == size(gP.cmap, 1)
                cmap = gP.cmap;
                if any(any(cmap > 1))
                    cmap = cmap / 255;
                end
                return;
            end
        case 'function_handle'
            if nColor == 1
                cmap = [0 0 0];
            else
                cmap = gP.cmap(nColor);
            end
            return
    end
end

switch nColor
    case 1, cmap = [0 0 0];
    case 2, cmap = [.7 .1 0; 0 .1 .7];
    case 3, cmap = [1 0 0; 0 .7 .2; 0 0 .7];
    case 4, cmap = [1 0 0; 0 1 .4; 0 0 .6; .8 0 1];
    case 5, cmap = [.5 0 0; 1 .4 0; .2 .6 .2; 0 .4 1; .8 0 1];
    case 'c', cmap = [0 1 1];
    case 'm', cmap = [1 0 1];
    case 'r', cmap = [1 0 0];
    case 'g', cmap = [0 1 0];
    case 'b', cmap = [0 0 1];
        
    otherwise
%         cmap = jet(nColor);
        cmap = linspecer(nColor);
end