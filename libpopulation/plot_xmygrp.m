function hP = plot_xmygrp(x, y, grp, varargin)
% plot population response to diferent stimuli
% plot_xmygrp(x,y,grp, sline)
% plot'm' means that y is a matrix
% x: (1 * n) preference of neurons OR time points
% y: (m trials * n) responses      OR (m trial * time points)
% grp: (m trials * 1) stimulus parameters
%
% 2017 HRK
sline = [];
show_individual = 1;
show_average = 1;
grp_name = {};
brighter_order = 3;
estimator = @nanmean;

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
    cL{iG} = sprintf('%.2f, n=%d', uG(iG), nnz(bVG) );
    if show_individual
        hInd = plot(x, y(bVG ,:)', sline , 'color', brighter(cmap(iG,:), brighter_order) );
        if ~isempty(hInd), hInd = hInd(1); end;
    end
    if show_average
        hAvg = draw_errorbar(x, estimator( y(bVG, :) ), nansem( y(bVG, :)), ...
            cmap(iG,:), 'patch', gca ) ;
        if ~isempty(hAvg), hInd = hAvg(1); end;
    end
    tmp = [hInd hAvg];
    hP(iG,:) = tmp;
end
hold off;

if ~isempty(grp_name)
    cL = grp_name;
end
legend(hP(:,1), cL);
stitle('n=%d', nnz(any(~isnan(y), 2)) );