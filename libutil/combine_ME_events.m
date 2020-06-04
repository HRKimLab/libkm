function evt = combine_ME_events(varargin)
% function combine_ME_events(varargin)

nT = size(varargin{1}, 1);

for iV = 1:numel(varargin)
    assert(size(varargin{iV}, 1) == nT, 'size of event should be same')
end

evt = NaN(nT, 1);

for iV = 1:numel(varargin)
    % find out valid values
   bV = ~isnan(varargin{iV});
   % make sure that those spots are NaNs
   assert( all(isnan(evt(bV))), 'more than one columns have valid values');
   % assign valid values
   evt(bV) = varargin{iV}(bV);
end
