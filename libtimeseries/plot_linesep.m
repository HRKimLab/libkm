function hP = plot_linesep(x, y, y_sep, varargin)

assert(length(x) == size(y, 1) )

nT = size(y,2);
% grid for separation
[y_idx] = meshgrid(1:nT, 1:length(x) );
% plot
hP = plot(x, y + y_idx * y_sep, varargin{:});
ylim([-y_sep y_sep * (nT+1)]);