function data = GenRegLineData(slope, intercept, xl,yl)
% generate line data points for linear regression
% 2015 HRK
if ~is_arg('yl'), yl = xl; end;

xl_by_yl = sort( (yl - intercept) / slope );

xl_final=NaN(1,2);
% take intersection of xl and xl_by_yl
if xl(1) > xl_by_yl(1)
    xl_final(1) = xl(1);
else
    xl_final(1) = xl_by_yl(1);
end

if xl(2) > xl_by_yl(2)
    xl_final(2) = xl_by_yl(2);
else
    xl_final(2) = xl(2);
end

x = linspace(xl_final(1), xl_final(2), 10)';
y = slope * x + intercept;

data = [x y];

return;