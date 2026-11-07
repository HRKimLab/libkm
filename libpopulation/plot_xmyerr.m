function [hPS hPL mY semY] = plot_xmyerr(x,y, varargin)
% PLOT_XMYERR Plot the average line plot with error bars, using x tick and
%   array data.
%   PLOT_XYERR(x, y) x is a row vector of [1 * n_time], y is a matrix of 
%    [n_observation) * (n_time)] (my means that y is a matrix). It iterate 
%    columns (e.g., time) and compute mean and s.e.m. across rows.
%    
%    Note that the number of columns in x should be matched with the number
%    of columns in y.
% 
% See also plot_xyerr, plot_xygrp, plot_xmygrp, plot_xyerr_wrt_tD_rows

% c, ebtype, raw_linestyle
color = [];
ebtype = [];		% old option (for compatibility)
errbar_type = [];	% new option 
individual_style = [];
show_individual = 1;
estimator = [];

process_varargin(varargin);

if ~is_arg('estimator'), estimator = @nanmean;end
% color is a reserved keyword. change variable name.
c = color; clear('color');
if ~is_arg('c'), c = [0 0 0]; end
if is_arg('errbar_type'), ebtype = errbar_type; end
if ~is_arg('ebtype'), ebtype = 'line'; end;
if ~is_arg('individual_style'), individual_style = 'o'; end;

% use median for now. doesn's makes lot of sense to use it with s.e.m.
% though..
if isempty(x), x = 1:size(y,2); end;

assert(size(x,2) == size(y,2), '# of column should be matched between x and y');

if show_individual
    if is_arg('c')
        hPS = plot(x, y, individual_style, 'color', brighter(c, 3), 'markersize', 5);
    else
        c = [0 0 0];
        hPS = plot(x, y, individual_style, 'markersize', 5);
    end
else
    hPS = [];
end

% mY = nanmedian(y, 1);
mY = estimator(y, 1);
% nT = nnz( all(~isnan(y), 2) );
% semY = nanstd(y, [], 1) / sqrt(nT);
nT = sum(~isnan(y));
semY = nanstd(y, [], 1) ./ sqrt(nT);
prev_np = get(gca,'nextplot'); set(gca, 'nextplot','add');
hPL = plot(x, mY, 'color', c, 'linewidth', 2);

hE = draw_errorbar(x, mY, semY, darker(c, 3), ebtype);
hPL = [hPL hE];
set(gca, 'nextplot', prev_np);
stitle('N=%d-%d, med=%.1f', min(nT), max(nT), median(nT));