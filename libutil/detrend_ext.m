function varargout = detrend_ext(varargin)
% detrend using linear regression, excluding NaNs
% it can take column vector or matrix. 
% Use the original indices for detrending.
% 2020 HRK

assert(nargin == nargout, '# of input and output args should be same');
for iV = 1:numel(varargin)
    assert(size(varargin{iV}, 1) > 1, 'input args should be column vector or matrix');
    varargout{iV} = NaN(size(varargin{iV}));
   for iC = 1:size(varargin{iV}, 2)
      % detrend column vector
      varargout{iV}(:, iC) = detrend_col(varargin{iV}(:, iC)); 
   end
end

function v = detrend_col(v)
% detrend a linear trend of column vector that may include NaNs
% assume that vector is data from indiviaul trials and use trial id
% for detrending
trial_id = (1:numel(v))';
bV = ~isnan(v);
% do linear regression
[b,bint,r,rint,stats] = regress(v(bV), [ones(size(trial_id(bV))), trial_id(bV)]);

v(bV) = r;