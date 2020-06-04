function h = errorbar_patch_opaque(x,y,er,c, ax)

%ERRORBAR_PATCH    - errorbar by patch
%
% ERRORBAR_PATCH(x,y,er,c) plots the graph of vector x vs. vector y with
%   error bars specified by the vector er.
%
%   input
%     - x:    
%     - y:    mean
%     - er:   error bar
%     - c:    color (vector of three values)
%
% eg.) 
%    x = [1 2 3 4];
%    y = [4 5 4 3];
%    er = [1.2 1.5 1 1.1];
%    c = [1 0 0];
%    errorbar_patch(x,y,er,c)
%


if nargin < 4
    c = [0 0 1];
end
if size(x,1) > size(x,2); x = x'; end
if size(y,1) > size(y,2); y = y'; end
if size(er,1) > size(er,2); er = er'; end
if ~is_arg('ax'), ax = gca; end

X = [x fliplr(x)];
if size(er,1) == 1
Y = [y+er fliplr(y-er)];
elseif size(er,1) == 2
    Y = [y+er(2,:) fliplr(y-er(1,:))];
end

assert(size(c,2) == 3, 'c should be 1 x 3 array instead of character')
patch_color = c * 0.4 + 0.6 *  [1 1 1];
% h1 = patch(X,Y,c,'edgecolor','none','FaceAlpha',0.2); hold on
if matlab_ver() < 8.4
    fa = 0.2;
else
    fa = 0.7;
end
h1 = patch(X,Y, patch_color,'edgecolor','none','FaceAlpha', fa, 'parent', ax); hold on
h2 = plot(ax, x,y,'color',c);

if nargout>0, h = [h1 h2]; end