function val = randrange_exp(m_val, maxval, rndtype)
% uniform randeom within the range
% HRK 6/25/2015

if ~is_arg('rndtype'), rndtype = 'uniform'; end;

if m_val > maxval;
    error('rangrange: m_val > maxval.');
end

cnt = 0;
val = exprnd(m_val);
while val > maxval
    val = exprnd(m_val);
    cnt = cnt + 1;
    if cnt > 1000
        warning('randrange_exp looped over 1000. just return maxval.');
        val = maxval;
        break;
    end
end
