function lim = setlim(x);
% set proper limits for axis
rg = range(x(:));
margin = rg * 0.07;
if margin == 0, margin = 1; end;
lim = [min(x(:))-margin max(x(:))+margin];

if isnan(margin)
    warning('setlim: all values are NaN.');
    lim = [-1 1];
end