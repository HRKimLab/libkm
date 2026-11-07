function append_TN(TN, gid, b_init)
% append TN to TNTr global variable
% 
% 2025 HRK
%
global gPopRsp

% this can be separated to init_gPopRsp
if is_arg('b_init') && b_init > 0
	MAX_TRIAL_NUM = 300;
	% initialize TNC
	gPopRsp.TNTr = zeros(size(TN, 1), size(TN, 2), MAX_TRIAL_NUM);
	% # of elements for each group
	gPopRsp.gids = nans(1, MAX_TRIAL_NUM);
	% current trial_index
	gPopRsp.trial_index = 0;
end

% check error
assert(gPopRsp.trial_index + 1 <= numel(gPopRsp.gids), 'trial # (%d) reached max limit', ...
	gPopRsp.trial_index);

% update # of element
gPopRsp.trial_index = gPopRsp.trial_index + 1;

% for debug
fprintf(1, '[%d %d] => gid %d (trial %d) \n', size(TN,1), size(TN, 2), gid, gPopRsp.trial_index);

% append
gPopRsp.TNTr(:, :, gPopRsp.trial_index) = TN;
gPopRsp.gids(gPopRsp.trial_index) = gid;