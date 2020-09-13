function y = figa2num(fids)
if isnumeric(fids)
    y = fids;
else
    y = arrayfun(@(x) x.Number, fids);
end
