function plot_multiple_xmyerr(x, data, varargin)
% PLOT_MULTIPLE_XMYERR plot multiple errorbar line plots (plot_xmyerr)
% 2020 HRK
cmap = [];
ebtype = 'bar';

process_varargin(varargin);

% get # of plots
nP = size(data, 3);

if isempty(cmap)
    cmap = get_cmap(nP);
end
hold on;
for iP = 1:nP
    plot_xmyerr(x, data(:,:,iP) ,'color', cmap(iP, :), 'ebtype', ebtype);
end
hold off;