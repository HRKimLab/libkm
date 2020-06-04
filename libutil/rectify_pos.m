function y = rectify_pos(x)

bV = x < 0;
x(bV) = 0;
y = x;