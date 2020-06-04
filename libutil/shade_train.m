function [hP1 hP2] = shade_train(ax, bTOI, pY, x)
% draw shading regions 
% 10/20/2017 HRK 
if nargin == 1 
    bTOI = ax; ax = gca;
elseif nargin == 2 && ~all(all(ishandle(ax)))
    pY = bTOI;
    bTOI = ax;
    ax = gca;
    pY = [];
end

if ~is_arg('pY')
    pY = [0 1];
end
if ~is_arg('x')
    x = 1:length(bTOI);
end

t = double(bTOI);
[on off] = detect_onoff(t, 0.5);
on = x(on); on = on(:);
off = x(off); off = off(:);
shade_plot(ax, [on off], pY);
return