function hP = plot_raster_array(x, array_resp, grp_idx, bSkipNaN, varargin)
%plot_raster_array: plot rasterplot
% array_resp: 2D array of trials X time(ms) having binary elements (0/1)
% grp_idx: array of group index 1..# of group
% HRK 7/2/2015
n_trial = size(array_resp,1);

if ~is_arg('bSkipNaN'), bSkipNaN = false; end;
raster_size = [];
ax = [];
cmap = [];

process_varargin(varargin);

assert(size(x,2) == size(array_resp,2));
assert(size(array_resp,1) == size(grp_idx,1));
if isempty(ax), ax = gca; end

% set color for grp_idx. since grp_idx has the same order as grp,
% I can just use the same grp2coloridx function to set color.
[tmp_cmap nColor] = grp2coloridx(grp_idx);
if isempty(cmap)
    cmap = tmp_cmap;
end

n_resp = NaN(n_trial,1);

% iterate trials
row_idx = 1;
% set marker size
est_ntrial = sum( ~isnan(grp_idx) & any(~isnan(array_resp),2) );
if  est_ntrial > 200
    marker_size = 2;
elseif est_ntrial > 100
    marker_size = 3;
elseif est_ntrial > 50
    marker_size = 4;
elseif est_ntrial > 25
     marker_size = 5;
else
     marker_size = 6;
end

if is_arg('raster_size'), marker_size = raster_size; end;

set(ax,'nextplot', 'add');

hP = [];
for iT = 1:size(array_resp,1)
    if all(isnan(array_resp(iT,:))) || isnan(grp_idx(iT)), n_resp(iT) = NaN;
    else n_resp(iT) = nansum(array_resp(iT,:)); end;

    if bSkipNaN && isnan(n_resp(iT)), 
        continue; 
    end; % skip
    
    resp_idx = find(array_resp(iT,:) > 0);
    % slow way. iterate individual responses and draw line
%     for k = 1:length(resp_idx)
%         plot( [x(resp_idx(k)) x(resp_idx(k))], [row_idx-0.5 row_idx+0.5], 'color', cmap(grp_idx(iT),:));
%     end
    % faster way. draw dots
%     plot( [x(resp_idx)], ones(length(resp_idx),1) * row_idx, '.', 'color', cmap(grp_idx(iT),:),'markersize',3);
     hP2 = plot(ax, [x(resp_idx)], ones(length(resp_idx),1) * row_idx, '.', 'color', cmap(grp_idx(iT),:),'markersize', marker_size);
    hP = [hP hP2];
    row_idx = row_idx + 1;
end
set(hP, 'tag', 'rastermarker');
set(ax,'nextplot', 'replace');


if row_idx == 1 % nothing to plot
    return;
end

draw_refs(0, 0, n_trial, ax);
set(ax ,'YDir', 'reverse'); % axis ij;
ylim(ax, [1 row_idx]);
xlim(ax, [x(1) x(end)]);
ylabel(ax, 'Trial');
stitle(ax, 'N=%d/%d (NaN=%d)', n_trial-nnan(n_resp), n_trial, nnan(n_resp));