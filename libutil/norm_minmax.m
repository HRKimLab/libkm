function y = norm_minmax(x, alpha, bAbsoluteValue)
if nargin == 1
    alpha = [0.01 0.99]; 
    mm = pick_alpha(x, alpha);
elseif nargin == 2
    mm = pick_alpha(x, alpha);
elseif nargin == 3
    assert(numel(alpha) == 2);
    mm = [alpha];
end

% normalize
y = (x - mm(1)) / diff(mm);