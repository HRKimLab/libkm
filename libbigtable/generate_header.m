function cH = generate_header(x, prefix)
if ~is_arg('prefix'), prefix = 'H'; end;
assert(numel(x) > 0, '# of elements is zero');

if numel(x) == 1
    x = 1:x;
else
    x = 1:size(x,2);
end

cH = arrayfun(@(y) sprintf('H%d', y), x, 'un',false);

cH = {'CELL', cH{:}};