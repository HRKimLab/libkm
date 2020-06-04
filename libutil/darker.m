function v = darker(c, rho)
if ~is_arg('rho'), rho = 1; end;

v = color2num(c);
for iR = 1:rho
    v = zeros(size(v)) * 0.2 +  v * 0.8;
end