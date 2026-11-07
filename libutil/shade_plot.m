function [hP1 hP2] = shade_plot(ax, TWs, pY, varargin)
% SHADE_PLOT draw shading regions on the axis.
%  shade_plot(ax, TWs, pY) 
%    ax: axis handle
%    TWs: array of time window [n_windows * 2]. The first element is start
%    of window, the second is end of window. You can plot multiple windows.
%    pY: Y range of the shadow. current bottom is 0, current top is 1.
% 
%  Examples:
%  shade_plot(gca, [-2 -1; 4 5], [.5 1]) create two shadow regions, [-2 1]
%  and [4 5] on the x axis. And it fills from the half to the top of the
%  plot.
%
% 10/20/2017 HRK 

cmap = [];

process_varargin(varargin);

if nargin == 1 
    TWs = ax; ax = gca;
elseif nargin == 2 && ~all(all(ishandle(ax)))
    pY = TWs;
    TWs = ax;
    ax = gca;
    pY = [];
end

if ~is_arg('pY')
    pY = [0 1];
end

if numel(ax) > 1
    ax = ax(:);
    for iA=1:numel(ax)
       shade_plot(ax(iA), TWs, pY);
    end
    return
end

hP1 = []; hP2 = [];
nWin = size(TWs, 1);

if ~is_arg('cmap')
    if nWin == 1
        cmap = [0.8 0.8 0.8];
    else
        % hsv based light colors
        cmap = (hsv(nWin)+4)/5 ;
    end
end

for iR = 1:nWin
    TW = TWs(iR, :);
    
    yl_orig = get(ax, 'ylim');
    % to deal with later ylim change 
%     yl(1) = min([-100000 yl_orig(1)]); yl(2) = max([100000 yl_orig(2)]);
    % for saving to pdf. noticed that pdf keeps the large ylim when getting
    % rid of mask
    yl = yl_orig;
    y_range = diff(yl);
    yl = [yl(1) + y_range * pY(1), yl(1) + y_range * pY(2)];
    if size(TW, 2) == 2
        hP1(iR,:) = patch([TW(1) TW(2) TW(2) TW(1)], [yl(1) yl(1) yl(2) yl(2)], 'k','parent',ax);
        hP2 = [];
        set(hP1(iR,:),'linestyle', 'none', 'facecolor', cmap(iR,:));
        uistack(hP1, 'bottom');
    elseif size(TW, 2) == 4
        hP1(iR,:) = patch([TW(1) TW(2) TW(2) TW(1)], [yl(1) yl(1) yl(2) yl(2)],'k','parent',ax);
        hP2(iR,:) = patch([TW(3) TW(4) TW(4) TW(3)], [yl(1) yl(1) yl(2) yl(2)],'k','parent',ax);
        set(hP1,'linestyle', 'none', 'facecolor', brighter(cmap(iR, 1)));
        set(hP2,'linestyle', 'none', 'facecolor',   darker(cmap(iR, 1)));
        % put shading at the bottom of UI stack
        uistack(hP1, 'bottom'); uistack(hP2, 'bottom');
    end
    
end
set(ax, 'ylim', yl_orig);

return