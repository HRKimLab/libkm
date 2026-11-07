function [hP mG semG] = plot_xyerr(x,y, varargin)
% PLOT_XYERR draw a line plot with errorbars.
%   PLOT_XYERR(x,y) x and y are [n_obs * 1] sized column vectors. 
%      for each unique value of x, it computes std or sem of y 
%      based on x, and draws a line plot with errorbars.
%
%   PLOT_XYERR(x,y, VARARGIN) 
%       errbar = 'sem' | 'std'
%
% See also PLOT_XYGRP, PLOT_XMYERR, PLOT_XMYGRP, PLOT_XYERR_WRT_TD_ROWS

% FYI, it was previously "[hP mG semG] = plot_xyerr(x,y, errbar_type)"
% if ~is_arg('errbar_type'), errbar_type = 'sem'; end;

errbar = 'sem';			% this used to be 'errbar_type' before 9/7/2024 HRK
errbar_type = 'bar';	% option name re-assigned.. 9/7/2024 HRK
estimator = @mean;

process_varargin(varargin);

cG = grpstats(y,x,'gname');
unique_x = cellfun(@(x) str2num(x), cG);

% compute mean and error bars for each x
mG = grpstats(y,x, estimator);
nG = grpstats(y,x,'numel');
% stdG = grpstats(y,x,'std');
% semG = stdG ./ sqrt(nG);
semG = grpstats(y,x, errbar);

% draw markers
hPS = plot(unique_x, mG, 'o');
c = get(hPS, 'color');
set(hPS, 'markersize', 4,'markerfacecolor', c);
prev_nextplot = get(gca,'nextplot'); % hold on;. wrong. just keep prev status
set(gca,'nextplot','add');

% draw error bars
% hPL = errorbar(unique_x, mG, semG);   9/7/2024
hPL = draw_errorbar(unique_x, mG, semG, [0 0 0], errbar_type);
set(gca,'nextplot', prev_nextplot); % hold off;

nN = length(x);
title(sprintf('N=%d, nG=%d', nN, length(cG)));

hP = [hPS hPL];