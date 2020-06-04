function hL = draw_refs(b_diag,x_ref, y_ref, ax)
% hL = draw_refs(b_diag,x_ref, y_ref) 
% draw x,y,diagonal line

hL = [];
%drawnow; sometimes it gets lim before data get plotted.
% store current xlim, ylim
if ~is_arg('ax'), ax = gca; end;
xl = get(ax,'xlim'); yl = get(ax,'ylim');
% in case we zoom out axes later, make xll and yll larger
xll = xl + [-100000 100000]; yll = yl + [-100000 100000];

%set(ax,'xlimmode','manual','ylimmode','manual');
if ~is_arg('b_diag'), b_diag = 1; end;


% x, y, diagonal

if b_diag == 2
    minval = min(min([xll; yll;]));
    maxval = max(max([xll; yll;]));
    abmax = max(abs([minval maxval]));
    tmp = line([abmax -abmax],[-abmax abmax], 'color','k','parent',ax);
    tmp = line([maxval minval],[minval maxval], 'color','k','parent',ax);
    hL = [hL; tmp];
elseif b_diag == 1
    % refline makes x,y axis same scale. sometimes I don't want this.
    minval = min(min([xll; yll;]));
    maxval = max(max([xll; yll;]));
    tmp = line([minval maxval],[minval maxval], 'color','k','parent',ax);
    hL = [hL; tmp];
end;

% additional x ref
if is_arg('x_ref') && all(isnan(x_ref))

elseif is_arg('x_ref')
    for i=1:length(x_ref)
        tmp = line([x_ref(i) x_ref(i)], yll,'color','k','parent',ax);
        hL = [hL; tmp];
    end
else
    tmp = line([0 0], yll,'color','k','parent',ax); 
    hL = [hL; tmp];
end

% additional y ref
if is_arg('y_ref') && all(isnan(y_ref))

elseif is_arg('y_ref') 
    for i=1:length(y_ref)
        tmp = line(xll, [y_ref(i) y_ref(i)], 'color','k','parent',ax);
        hL = [hL; tmp];
    end
else
    tmp = line(xll, [0 0],'color','k','parent',ax); 
    hL = [hL; tmp];
end


set(hL, 'tag','ref');
% restore xlim, ylim
set(ax,'xlim',xl, 'ylim',yl);