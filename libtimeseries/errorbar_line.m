function h = errorbar_line(x, y, err, varargin)
np = get(gca,'nextplot');
h=[];
h1 = plot(x, y, varargin{:}, 'linewidth', 1);
hold on;
h2 = plot(x, y + err, 'linestyle', ':', varargin{:});
plot(x, y - err, 'linestyle', ':', varargin{:});
set(gca,'nextplot', np);
% mean goes first
h = [h2 h1];