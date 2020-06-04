function xl = pick_alpha(x, p_cdf)
% x: m * n 
% p_cdf: 1 * p
% xl: n * p

warning('Use prctile intead of this!');

%if size(x, 1) == 1, x = x(:); end
x = x(:); 

xl = NaN(length(p_cdf), size(x, 2) );

for iC = 1:size(x, 2)
    sorted_x = sort( nonnans(x(:, iC)) );
    if isempty(sorted_x), continue; end;
    
    for iP = 1:length(p_cdf)
        nlen = length(sorted_x);
        ord = nlen * p_cdf(iP);
        if ord < 1, ord = 1; end;
        xl(iP, iC) = sorted_x( round(ord));
    end    
end