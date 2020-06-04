function iCells = findcells(iX, iY)
% find cell indentifiers from data or index of aPD data array.
% iX, iY can be either column index of aPD, or array values themselves.

% retrieve aPD
aPD = evalin('caller','aPD');
pcd_colname = evalin('caller','pcd_colname');

% use mouse to select range using two points
disp('define a retangular area of interest by clicking on the top left and right bottom');
[x_range y_range] = ginput(2)
x_range = sort(x_range), y_range = sort(y_range)

if length(iX) == 1
    x = aPD(:,iX);
else
    x = iX;
end

% find index of cells
bX = (x -x_range(1)) .* (x -x_range(2)) < 0;

if is_arg('iY')
    if length(iY) == 1
        y = aPD(:,iY);
    else
        y = iY;
    end
    bY = (y - y_range(1)) .* (y - y_range(2)) < 0;
else
    bY = bX;
end

% find indeces which satisfy both conditions
bV = bX & bY;
if length(iX) == 1 && length(iY) == 1
    fprintf(1,'%10s\t',pcd_colname{[1:5 iX iY]}); fprintf(1,'\n');
end
% spit out cell identifiers
[aPD(bV, 1:5) x(bV) y(bV)]
iCells = find(bV');