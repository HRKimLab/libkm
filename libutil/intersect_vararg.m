function r = intersect_vararg(varargin)
% intersect with variable argument
% 2022 HRK
r = varargin{1};
for iV = 1:numel(varargin)
    r = intersect(r, varargin{iV} );
end