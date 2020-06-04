function reverse_log(x, y, xy)
% lim: ex) [1 20] 
% ax: 'x' or 'y'
% stop implementing.. not working for now. just leave as it as.


if xy == 'x'
   maxval = max(x(:));
   x =  maxval + 1 - x; 
else
    maxval = max(y(:));
   y = maxval + 1 - y;
end

plot(x, y)

if xy == 'x'
    set(gca,'xdir','reverse','xscale','log')
else
    %# reverse y-axis
    set(gca,'ydir','reverse','yscale','log')

    %# if necessary, set the axis limits here

    %# relabel y-axis
%     set(gca,'yticklabel',num2str(maxval - 10.^str2num(get(gca,'yticklabel'))))
end