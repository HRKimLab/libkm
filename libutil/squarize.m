function squarize(xl)
% make axes square, and draw reference lines
if nargin == 0
    xl = [min([xlim ylim]'); max([xlim ylim]')];
end
if xl(1) == xl(2)
    xl(2) = xl(1) + 1;
end
axis equal; xlim(xl); ylim(xl);
draw_refs;