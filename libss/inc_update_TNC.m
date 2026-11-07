function inc_update_TNC(TN, gid, init_n_grp, varargin)
% compute mean and variance incrementally using Welford's algorithm
% referring to https://kr.mathworks.com/matlabcentral/answers/414314-implementing-welford-s-algorithm-incremental-variance-calculation#:~:text=%23%20mean%20accumulates%20the%20mean%20of,else:
% 
% 2025 HRK
%
global gPopRsp

% this can be separated to init_gPopRsp
if is_arg('init_n_grp') && init_n_grp > 0
	MAX_GRP_NUM = init_n_grp;
	% initialize TNC
	gPopRsp.TNC = zeros(size(TN, 1), size(TN, 2), MAX_GRP_NUM);
	% M2 (intermidiate value to compute variance)
	gPopRsp.M2  = zeros(size(TN, 1), size(TN, 2), MAX_GRP_NUM);
	% sample variance
	gPopRsp.Var_sample = zeros(size(TN, 1), size(TN, 2), MAX_GRP_NUM);
	% # of elements for each group
	gPopRsp.n_numel = zeros(1, MAX_GRP_NUM);
end

% check error
assert(gid <= size(gPopRsp.TNC, 3), 'gid (%d) > size(TNC, 3) (%d)', ...
	gid , size(gPopRsp.TNC, 3) );

% for debug
fprintf(1, '[%d %d] => gid %d \n', size(TN,1), size(TN, 2), gid);

% update # of element
gPopRsp.n_numel(gid) = gPopRsp.n_numel(gid) + 1;

% update delta
delta = TN - gPopRsp.TNC(:, :, gid);

% update mean
% old way
% gPopRsp.TNC(:, :, gid) = (gPopRsp.TNC(:, :, gid) * (gPopRsp.n_numel(gid)-1) + TN) / (gPopRsp.n_numel(gid));
gPopRsp.TNC(:, :, gid) = gPopRsp.TNC(:, :, gid) + delta / gPopRsp.n_numel(gid);

delta2 = TN - gPopRsp.TNC(:, :, gid);
gPopRsp.M2(:,:, gid) = gPopRsp.M2(:,:, gid) + delta .* delta2;

% compute sample variance
if gPopRsp.n_numel(gid) > 1
	gPopRsp.Var_sample(:,:, gid) = gPopRsp.M2(:,:, gid) / (gPopRsp.n_numel(gid)-1);
else
	gPopRsp.Var_sample(:,:, gid) = NaN(size(gPopRsp.M2(:,:, gid)));
end

% for debug
% imagesc( TCN2ss( permute(gPopRsp.TNC, [1 3 2]) ) )
% imagesc( TCN2ss( permute(gPopRsp.Var_sample, [1 3 2]) ) )
