function set_default_figure_properties()
% 2020 HRK
% font_unit = 'points';
% set(groot, 'defaultfigurewindowstyle', 'normal');
% set(groot, 'defaultfigureposition', [100 100 400 400]);
% set(groot, 'defaultlinewidth', 1);
set(groot, 'defaultaxestickdir', 'out');
set(groot, 'defaultAxesTickDirMode', 'manual');
% increase tick length a bit
set(groot, 'defaultaxesticklength', [0.013 0.025]);
set(groot, 'defaultaxesticklengthmode','manual');
% erase box outline
set(groot, 'defaultaxesbox','off');
% reduce # of ticks if necessary
% reduce_axis_tick(hA);