function hP = plot_xmygrp(x, y, grp, varargin)
% PLOT_XMYGRP plot averaged line plots with error bars for each group
%   PLOT_XMYGRP(x,y,grp) draw line plots and error bars for each group.
%    x is a row vector of [1 * n_time]
%    y is a matrix of [n_observation) * (n_time)] (my means that y is a matrix). 
%    grp is [n_observations * 1]
%
%    For each grp, it filters in x and y. 
%    It iterate column (e.g., time) and compute mean and s.e.m. across rows of y.
%    
%    Note that the following condition should meet: 
%    - (# of columns in x) == (# of columns in y). 
%    - (# of rows in grp) == (# of rows in y).

% 2017 HRK
sline = [];
show_individual = 1;
show_average = 1;
grp_name = {};
brighter_order = 3;
estimator = @nanmean;
errbar_type = 'patch' ;

process_varargin(varargin);

if ~is_arg('grp')
    grp = ones(size(y,1),1);
end

assert(size(x,2)==size(y,2), 'size(x,2): %d should be same as size(y,2): %d', size(x,2), size(y,2));
assert(size(y,1)==size(grp,1), 'size(y,1): %d should be same as size(grp,1): %d', size(y,1), size(grp,1));

if ~is_arg('sline'), sline = '-'; end;

uG = unique(grp);

assert(isempty(grp_name) || numel(uG) == numel(grp_name), '# of groups should match with # of group names');
cmap = get_cmap(numel(uG));
cla; hold on;
hInd = []; hAvg = []; cL = {};
for iG=1:length(uG)
    bVG = grp == uG(iG);
    cL{iG} = sprintf('%.2f, n=%d', uG(iG), nnz( any(y(bVG, :), 2) ) );
    if show_individual
        hInd = plot(x, y(bVG ,:)', sline , 'color', brighter(cmap(iG,:), brighter_order) );
        if ~isempty(hInd), hInd = hInd(1); end;
    else
        hInd = NaN;
    end
    hP(iG,:) = hInd;
end

tmp_hP = [];
for iG = 1:length(uG)
    bVG = grp == uG(iG);
    if show_average
        hAvg = draw_errorbar(x, estimator( y(bVG, :) ), nansem( y(bVG, :)), ...
            cmap(iG,:), errbar_type, gca ) ;
        if ~isempty(hAvg), hInd = hAvg(1); end;
    end
    tmp_hP(iG, :) = hAvg;
end
hP = [hP tmp_hP];

hold off;

if ~isempty(grp_name)
    cL = grp_name;
end
if any(ishandle(hP(:,2)))
    legend(hP(:,2), cL);
end
stitle('n=%d', nnz(any(~isnan(y), 2)) );