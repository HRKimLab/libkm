function v = color2ar(c)
if isnumeric(c)
    assert(size(c,2) == 3, 'c should be n * 3 numeric');
    v = c; 
    return; 
end;

if ~ischar(c)
    error('c is neither n * 3 color numeric or a single character');
end

switch(c)
    case 'b', v = [0 0 1]; 
    case 'g', v = [0 1 0]; 
    case 'r', v = [1 0 0]; 
    case 'c', v = [0 1 1]; 
    case 'm', v = [1 1 0]; 
    case 'y', v = [1 0 1]; 
    case 'k', v = [0 0 0]; 
    case 'w', v = [1 1 1]; 
end