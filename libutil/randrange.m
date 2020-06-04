function val = randrange(min_or_meanval, maxval, rndtype)
% uniform randeom within the range
% HRK 6/25/2015

if ~is_arg('rndtype'), rndtype = 'uniform'; end;

% multiple 
if size(min_or_meanval, 1) > 1 && size(min_or_meanval, 1) == size(maxval, 1)
    nT = size(min_or_meanval, 1);
    val = NaN(nT, 1);
   for iT = 1:nT
      val(iT) = randrange(min_or_meanval(iT), maxval(iT), rndtype); 
   end
   return
end
    
if any(min_or_meanval > maxval)
    warning('rangrange: min_or_meanval > maxval. return NaN');
    val = NaN;
end
switch rndtype
    case 'uniform'
        val = min_or_meanval + rand(size(min_or_meanval)) .* (maxval - min_or_meanval);
    case 'exp' % mean, max
        val = exprnd(min_or_meanval);
        while val > maxval
            val = exprnd(min_or_meanval);
        end
    otherwise
        error('Unknown type: %s', rndtype);
end