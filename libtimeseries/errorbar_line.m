function h = errorbar_line(x, y, err, varargin)
np = get(gca,'nextplot');
h=[];
h(2) = plot(x, y, varargin{:}, 'linewidth', 1);
hold on;
h(1) = plot(x, y + err, 'linestyle', ':', varargin{:});
plot(x, y - err, 'linestyle', ':', varargin{:});
set(gca,'nextplot', np);