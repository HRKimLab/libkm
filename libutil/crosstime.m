function t = crosstime(x, thres, mode)

if ~is_arg('mode'), mode = 'all'; end

y = (x - thres);

bPosCross = y(1:end-1) <= 0 & y(2:end) > 0;
bNegCross = y(1:end-1) >= 0 & y(2:end) < 0;

t = find(bPosCross | bNegCross);

switch(mode)
    case 'first'
        if isempty(t)
            t = NaN;
        else
            t = t(1);
        end
    case 'last'
        if isempty(t)
            t = NaN;
        else
            t = t(end);
        end
end