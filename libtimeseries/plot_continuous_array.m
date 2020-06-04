function hP = plot_continouse_array(x, array_resp, grp_idx, bSkipNaN, ax)
% I switched to image_continuous_array, but just leave it for compatibility
% grp_idx: array of group index 1..# of group
% HRK 7/2/2015
n_trial = size(array_resp,1);

if ~is_arg('bSkipNaN'), bSkipNaN = false; end;
if ~is_arg('grp_idx'), grp_idx = ones([size(array_resp,1) 1]); end;
if ~is_arg('ax'), ax = gca; end;

assert(size(x,2) == size(array_resp,2));
assert(size(array_resp,1) == size(grp_idx,1));

% set color for grp_idx. since grp_idx has the same order as grp,
% I can just use the same grp2coloridx function to set color.
[cmap nColor] = grp2coloridx(grp_idx);

% n_resp = NaN(n_trial,1);
set(ax, 'nextplot','add'); % hold on;

if bSkipNaN
    n_resp = ~all(isnan(array_resp),2) & ~isnan(grp_idx);
else
    n_resp = true(size(array_resp,1), 1) & ~isnan(grp_idx);
end

row_idx = 0;
if size(x,1) == 1 % x is time
    imagesc(x, 1:nnz(n_resp), array_resp(n_resp,:),'parent',ax); 
else % x is another x(t), such as distance traveled
    assert(0, 'this is not implemented yet');
    % accumate color-coded patch
    set(ax,'nextplot','add'); % hold on;
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
        hP = pcolor(ax, [x(iT, bV); x(iT, bV)], repmat([row_idx-0.5; row_idx+0.5], [1 nnz(bV)]), [array_resp(iT, bV); array_resp(iT, bV)])
        
%         if sum( array_resp(iT, bV) ) > 0
%             keyboard;
%         end
    end
    set(ax,'nextplot', 'replace'); hold off;
end
p_axes = get(gca, 'position');
h_colorbar = colorbar('east','peer', ax);
set(h_colorbar, 'YAxisLocation','right')
pos_colorbar = get(h_colorbar,'position');
set(h_colorbar, 'position', [p_axes(1)+p_axes(3)+pos_colorbar(3)*0.1 pos_colorbar(2)+pos_colorbar(4)/4 pos_colorbar(3)/2 pos_colorbar(4)/2]); 

% mark group at the right side of plot
hold on;
if n_trial < 20, marker_size = 6;
elseif n_trial < 100, marker_size = 4;
else, marker_size = 2; end
for iG = 1:nColor
   hP(iG,:) = plot(ax, x(end) * ones(nnz(grp_idx == iG),1),  find(grp_idx == iG), 's', ...
       'color', cmap(iG,:), 'markerfacecolor', cmap(iG,:), 'markersize', marker_size);
end
hold off;

draw_refs(0, 0, NaN, ax); % n_trial + 0.5
set(ax, 'YDir','reverse');
ylim(ax, [0.5 nnz(n_resp)+0.5]);
if size(x,1) == 1, xlim(ax, [x(1) x(end)]);
else xlim(ax, minmax(x(:))); end
ylabel(ax, 'Trial');
stitle(ax, 'N=%d/%d (NaN=%d)', n_trial-nnz(n_resp==0), n_trial, nnz(n_resp==0));