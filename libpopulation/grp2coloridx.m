function [cmap nColor grp_idx gname gnumel] = grp2coloridx(grp, grp_lim)
% find group to use for color coding and gourp comparison
% It is the first group with group # < 10

if ~is_arg('grp_lim')
    grp_lim = 10;
end

nColor = 1;
grp_idx = ones(size(grp, 1), 1);
% default if cannot find proper group variables
gname = {'1'}; gnumel = size(grp,1);
for iG = 1:size(grp,2)
   if length(unique(nonnans(grp(:, iG)))) <= grp_lim
      [~, grp_idx] = ismember(grp(:,iG), unique(nonnans(grp(:,iG))) );
      [gname, gnumel] = grpstats(grp(:,iG), grp(:, iG), {'gname', 'numel'});
      assert( all(diff(cellfun(@str2num, gname)) > 0) ); % make sure it's increasing order
      % convert 0 to NaN
      grp_idx(grp_idx == 0) = NaN;
      nColor = length(unique(nonnans(grp(:, iG))));
      break;
   end
end

cmap = get_cmap(nColor);