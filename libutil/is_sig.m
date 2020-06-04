function sig = is_sig(x, alpha)
% check significance
% boolean value cannot have NaN. so, the result of NaN < 0.05 is 0.
% however, this is not suitable for the convention that any result of NaN should be 
% NaN, expecially for marking significance.
% so, make the return value to double, and apply NaN if x is NaN.

if ~is_arg('alpha'), alpha = 0.05; end;

if length(x) == 1
    x_label = evalin('base', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('caller', ['aPD(:,' num2str(x) ');']);
end

sig = double(x < alpha);
sig(isnan(x)) = NaN;