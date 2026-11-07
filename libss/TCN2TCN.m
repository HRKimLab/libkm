function rspTCN = TCN2TCN(rspTCN, varargin)
% TCN2TCN preprocess TCN data 
%  rspTCN = TCN2TCN(rspTCN, varargin) perform various preprocessing,
%  e.g., filtering, smoothing, z-scoring for the TCN data.
%  the return value then can be used for further population data analysis.
% 
% Note: When you add a new preprocessing method, be mindful that 
% the order of the preprocessing might matter if it is a nonlinear process. 
%
% See also TCN2ss, ss2TCN
%
% 2024 HRK

norm_method = 'none';  % normalize data
smooth_win = [];

process_varargin(varargin);

%% normalize responses
switch(norm_method)
    case 'none'
    case 'zscore'
        rspTCN = zscore(rspTCN, [], 1);
    otherwise
        error('Unknown norm method: %s', norm_method);
end

%% smooth responses
if is_arg('smooth_win')
   for iN = 1:size(rspTCN, 3)
       sm_kernel = ones(smooth_win, 1) / smooth_win;
       % smooth using conv2 along the time dimension
       rspTCN(:, :, iN) = conv2(rspTCN(:, :, iN), sm_kernel, 'same');
   end
end