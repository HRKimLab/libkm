function color_legend(hL)
% color legend text based on the color of line/symbol 
% 12/14/2017 HRK
ch = get(hL, 'child');
iG = 1;
for iC = 1:length(ch)
    tp = get(ch(iC), 'type');
    switch(tp)
        case 'line'
            % invalidate line
%             set(ch(iC), 'linestyle', 'none');
        case 'text'
            if isempty(get(ch(iC),'string')), continue; end
            % find line with the tag of this text
            hObj = findobj(hL,'tag', get(ch(iC),'string'));
            assert(~isempty(hObj));
            % skip it for now if hObj is hggroup. it's like 3 children
            % below. 
            if strcmp( get(hObj,'type'), 'hggroup'), continue; end
            % change text color and align it front
            if size( get(hObj, 'color'), 1 ) == 1
                set(ch(iC), 'color', get(hObj, 'color'));
            else
                warning('more than one mating tag: %s', get(ch(iC),'string'));
            end
            % change the position
%             pos = get(ch(iC),'position');
%             set(ch(iC),'position', [0.1 pos(2) pos(3)])
            
            iG = iG + 1;
    end
end
