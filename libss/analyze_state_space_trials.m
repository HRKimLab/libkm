function [ss_rsp rspTCN] = analzye_state_space_trials(rspTNTr, gid, varargin)
% ANALYZE_STATE_SPACE basic state space analysis
% 
% 
% RETURN VALUE:
% psth: psth struct that contains results of grouping.
% psth.mean: [nTime nGroup nNeuron]
%  
% TODO: incorporate plot_timecourseMD (below is from plot_timecourseMD or compute_avggrpMD)
% rate_rsp [nTime nTrial nNeuron] based on grp [nTrial 1]. 
% Make grp element to NaN if trigger or windows is not valid
% 
% TODO: change rate_rsp to [nTime nNeuron nTrial]
%
% RETURN VALUES:
%  ss_rsp: [(time*condition) x neuron]
%  rspTCN: [time x condition x neuron]
%
%  Note: TCN has more information than ss ([(time*cond) x neuron]) since 
%  dimensions are not merged. It is better to deal with NaN issue.
%
% See also cluster_psths, TCN2ss, ss2TCN, TCN2TCN
% 
% 2022 HRK

norm_method = 'zscore';  % normalize data

process_varargin(varargin);

nTime = size(rspTNTr, 1);
nNeuron = size(rspTNTr, 2);
nTrial = size(rspTNTr, 3);

% average cross trials and contruct TCN
rspTNC = TNTr2TNC(rspTNTr, gid);

nCond = size(rspTNC, 3);

rspTCN = permute(rspTNC, [1 3 2]);

analyze_state_space(rspTCN, varargin{:})

% plot inidivisual trial trajectories


% compute pairwise distance
for iT = 1:nTime
	pd = pdist( squeeze( permute( rspTNC(iT, :, :), [3 2 1] ) ) );
end