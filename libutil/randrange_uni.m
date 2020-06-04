function val = randrange_uni(minval, maxval, rndtype)
% uniform randeom within the range
% HRK 6/25/2015

if ~is_arg('rndtype'), rndtype = 'uniform'; end;

if minval > maxval;
    warning('rangrange: minval > maxval. return NaN');
    val = NaN;
end

val = minval + rand(1) * (maxval - minval);
    