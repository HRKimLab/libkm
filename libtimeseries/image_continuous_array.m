function hP = image_continouse_array(x, array_resp, varargin)
% function hP = image_continouse_array(x, array_resp, grp_idx, bSkipNaN,
% grp_lim, xl, ax) changed to varargin 1/14/2019 HRK
% grp_idx: array of group index 1..# of group
% HRK 7/2/2015

grp_idx = [];
bSkipNaN = [];
grp_lim = [];
xl = [];
ax = [];
cmap = [];
show_colorbar = 1;
adjust_clim = 0; % adjust clim for imagesc to be 1-99% to exclude outliers in the color range
clim = [];

process_varargin(varargin);

n_trial = size(array_resp,1);

if ~is_arg('bSkipNaN'), bSkipNaN = false; end;
if ~is_arg('grp_idx'), grp_idx = ones([size(array_resp,1) 1]); end;
if ~is_arg('grp_lim'), grp_lim = 10; end;
if ~is_arg('xl'), 
    if size(x, 1) == 1,  xl = [x(1) x(end)];
    else, xl = minmax(x(:));
    end
end
if ~is_arg('ax'), ax = gca; end;

assert(size(x,2) == size(array_resp,2));
assert(size(array_resp,1) == size(grp_idx,1));

% set color for grp_idx. since grp_idx has the same order as grp,
% I can just use the same grp2coloridx function to set color.
[tmp_cmap nColor] = grp2coloridx(grp_idx, grp_lim);
if isempty(cmap)
    cmap = tmp_cmap;
end

% n_resp = NaN(n_trial,1);
set(ax, 'nextplot', 'add');

if bSkipNaN
    % at least one data point should be non-NaN
    n_resp = ~all(isnan(array_resp),2) & ~isnan(grp_idx);
else
    n_resp = true(size(array_resp,1), 1) & ~isnan(grp_idx);
end

row_idx = 0;
if size(x,1) == 1 % x is time
    imagesc(x, 1:nnz(n_resp), array_resp(n_resp,:), 'parent', ax); 
else % x is another x(t), such as distance traveled
    assert(0, 'this is not implemented yet');
    % accumate color-coded patch
    set(ax, 'nextplot', 'add')
    for iT = 1:n_trial
        % skip NaN rows
        if n_resp(iT) == 0 && bSkipNaN, continue; end;
        row_idx = row_idx + 1;
        % use distinct x for correponding array_resp
        bV = ~isnan(x(iT,:)); %& ~isnan(array_resp(iT,:));
        % I cannot use image. image just make equal spaced plot between
        % 1 and end.
%         imagesc(x(iT, bV), row_idx, array_resp(iT, bV));
%         surf(x(iT, bV), row_idx, array_resp(iT, bV));
        hP = pcolor([x(iT, bV); x(iT, bV)], repmat([row_idx-0.5; row_idx+0.5], [1 nnz(bV)]), [array_resp(iT, bV); array_resp(iT, bV)], 'parent', ax)
        
%         if sum( array_resp(iT, bV) ) > 0
%             keyboard;
%         end
    end
    set(ax, 'nextplot','rplace');
end

% re-locate colorbar
p_axes = get(ax, 'position');
h_colorbar = colorbar('peer', ax, 'east');
set(h_colorbar, 'YAxisLocation','right','TickDir','out')
pos_colorbar = get(h_colorbar,'position');
% set(h_colorbar, 'position', [p_axes(1)+p_axes(3)+pos_colorbar(3)*0.1 pos_colorbar(2)+pos_colorbar(4)/4 pos_colorbar(3)/2 pos_colorbar(4)/2]); 
set(h_colorbar, 'position', [p_axes(1)+p_axes(3)+p_axes(3)*0.05 pos_colorbar(2)+pos_colorbar(4)/6 ...
    p_axes(3)*0.03 pos_colorbar(4)/6*4]); 
% black line is bothering when preparing figures
box(h_colorbar, 'off');

% delete colorbar if needed
if ~show_colorbar, delete(h_colorbar); end

iGrpChanged = find( abs(diff(grp_idx(~isnan(grp_idx))) ) > 0);
% draw split line if trials are ordered by group
if length(iGrpChanged) <= grp_lim
    hG = draw_refs(0, NaN, iGrpChanged+0.5, ax); % n_trial+0.5);
    set(hG, 'tag','split');
end

% zero line on x axis
draw_refs(0, 0, NaN, ax); % n_trial+0.5);

% axis ij;
set(ax, 'YDir', 'reverse');
if n_resp == 0
%     ylim([0.5 nnz(n_resp)+0.5]);
else
    ylim(ax, [0.5 nnz(n_resp)+0.5]);
end

% copied from plot_timecourse
% adjust color range by percentile
if ~isempty(findobj(ax,'type','image')) && adjust_clim  ~= 0
    sorted_array_resp = sort( nonnans(array_resp) );
    if ~isempty(sorted_array_resp)
        nlen = length(sorted_array_resp);
        if nlen > 2
            adjust_cl(1) = sorted_array_resp( round(nlen * adjust_clim / 100));
            adjust_cl(2) = sorted_array_resp( round(nlen * (100-adjust_clim) / 100));
            if diff(adjust_cl) > 0,  set(ax,'clim', adjust_cl); end;
        end
    end
end

% adjust color range by absolute value
if ~isempty(clim)
    set(ax,'clim', clim);
end

xlim(ax, xl);
ylabel(ax, 'Trial');
stitle(ax, 'N=%d/%d(-%d)', n_trial-nnz(n_resp==0), n_trial, nnz(n_resp==0));