function [r,p,N,sl,itc,fitdata,pSR, hS] = plotsqscatter(x,y,grp,varargin)
% regdata: [x y basic_#(N;r;p) fit_params(sl;itc)
% substitute x if given as column idx
% HRK
show_individual = 1;
show_grpmean = 0;
grp_zscore = 0;     % 1: zscore 2: subtract mean
xl = [];
show_regress_ci = 0;
marker_size = [];
regress_type = 'type2';

process_varargin(varargin);

if length(x) == 1
    x_label = evalin('base', ['pcd_colname{' num2str(x) '}']); 
    x = evalin('base', ['aPD(:,' num2str(x) ');']);
elseif ~isempty(inputname(1))
    x_label = inputname(1);
end
% substitute y if given as column idx
if length(y) == 1
    y_label = evalin('base', ['pcd_colname{' num2str(y) '}']); 
    y = evalin('base', ['aPD(:,' num2str(y) ');']);
elseif ~isempty(inputname(2))
    y_label = inputname(2);
end

% substitute grp if given as column idx
if ~is_arg('grp')
    grp = zeros(size(x)); 
elseif length(grp) == 1
    grp = evalin('base', ['aPD(:,' num2str(grp) ');']);
end

% set x and y limits
if ~is_arg('xl')
    ranges=[setlim(x(:)) setlim(y(:))];
    xl = [min(ranges) max(ranges)]; 
    yl = xl;
else
    yl = xl;
end

if grp_zscore == 1
    xl = [-3 3]; yl = [-3 3]; 
end

[r,p,N,sl,itc,fitdata,hS] = plot_scatter(x,y,grp,'xl',xl,'yl',yl, 'show_individual', show_individual, ...
    'show_grpmean', show_grpmean, 'grp_zscore', grp_zscore, 'show_regress_ci', show_regress_ci, 'marker_size', marker_size, ...
    'regress_type', regress_type);

if ~is_arg('yl') || all(xl == yl)
    yl=xl;
    % make axes square
    squarize(xl);
else
    xlim(xl); ylim(yl); draw_refs; 
    % occationally draw_refs distroy unequal axis. just do it again.
    xlim(xl); ylim(yl); 
end

if all(isnan(x)|isnan(y))
    pSR = NaN;
else
    pSR = signrank(x,y);
end
atitle(sprintf('x<>y (p=%s)', p2s(pSR)));

return;
