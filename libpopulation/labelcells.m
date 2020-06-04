function labelcells(x, y, monkid, cellid)
% find cell indentifiers from data or index of aPD data array.
% iX, iY can be either column index of aPD, or array values themselves.

assert(size(x,1) == size(y,1));
if is_arg('monkid')
    assert(size(x,1) == size(monkid,1));
end
if is_arg('cellid')
    assert(size(x,1) == size(cellid,1));
end

for iC=1:size(x,1)
    if ~is_arg('monkid')
        cell_label = sprintf('%d', cellid(iC));
    else
        cell_label = sprintf('m%dc%d', monkid(iC), cellid(iC));
    end
   text(x(iC), y(iC),  cell_label);
end