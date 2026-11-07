function rspTNC = TNTr2TNC(rspTNTr, gid, varargin)
% rspTNTr: [Time x Neuron x Trial]
% gid : [1 x Trial] containing group ids
%
% rspTNC : [Time x Neuron x Cond]
%
% 2025 HRK

% use Y:\NeuRLab\paper_code_data\Mante2013\nansuite\
func = @nanmean; % make sure that 2nd argument of this function is dimension
n_cond = [];	 % max # of condition

process_varargin(varargin);


nTime = size(rspTNTr, 1);
nNeuron = size(rspTNTr, 2);
nTrial = size(rspTNTr, 3);

% parameter checks
% # of trial
assert(nTrial == numel(gid), '# of 3rd dim (%d) is trials, which should match with # of gid (%d)', ...
	nTrial, numel(gid) );

% check gid
assert(max(gid) < 100, 'max gid (%d) is too large', max(gid) );
assert(isempty( setdiff(unique(gid), 1:max(gid)) ), 'gid should be integers of [1:n_group]');
missing_gids = setdiff(1:max(gid), unique(gid));
if ~isempty(missing_gids) 
	warning('some gids are missing: %s', sprintf('%d ', missing_gids(:) ));
end

if isempty(n_cond)
	nCond = max(gid);
else
	nCond = n_cond;
end

% initialize TNC variable
rspTNC = NaN(nTime, nNeuron, nCond);

% iterate condition
for iC = 1:max(gid)
	% compute statistics across trials (3rd dim.)
	rspTNC(:, :, iC) = func(rspTNTr(:, :, gid == iC), 3);
end