function h = errorbar_patch_transparent(x,y,er,c,ax)
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
if size(x,1)>size(x,2); x = x'; end
if size(y,1)>size(y,2); y = y'; end
if ~is_arg('ax'), ax = gca; end

X = [x fliplr(x)];
Y = [y+er fliplr(y-er)];

h1 = patch(X,Y,c,'edgecolor','none','FaceAlpha',0.3, 'parent', ax); hold on
h2 = plot(ax, x,y,'color',c);

if nargout>0, h = [h1 h2]; end