function [res ss_rsp rspTCN] = analzye_state_space_TNC(rspTNC, varargin)
% ANALYZE_STATE_SPACE basic state space analysis
% 
%  
% TODO: incorporate plot_timecourseMD
%
% RETURN VALUES:
%  ss_rsp: [(time*condition) x neuron]
%  rspTNC: [time x neuron x condition]
%
%  Note: TCN has more information than ss ([(time*cond) x neuron]) since 
%  dimensions are not merged. It is better to deal with NaN issue.
%
% See also analyze_state_space, cluster_psths, TCN2ss, ss2TCN, TCN2TCN
% 
% 2022 HRK

norm_method = 'zscore';  % normalize data
dist_method = 'euclidean'; % method for pairwise distance
dim_method = 'pca';		  % unsupervised dim. reduction method
decode_method = '';		  % supervised decoding method (TODO)
traj_cmap = '';          % color map for each condition
iCond = [];              % conditions indice for visualization
neuron_label = [];
grp_label = [];
animation = 0;
sampling_rate = 100; % 100Hz (10ms bin)

process_varargin(varargin);

nTime = size(rspTNC, 1);
nNeuron = size(rspTNC, 2);
nCond = size(rspTNC, 3);

% get ss response
ss_rsp = TNC2ss(rspTNC);

if isempty(iCond)
    iCond = 1:nCond;
end

% double check the integrity of data and options
assert(isempty(grp_label) || numel(grp_label) == nCond, ...
    '# of grp_label should match with # of groups');
assert(isempty(traj_cmap) || size(traj_cmap, 1) == nCond, ...
    '# of traj_cmap should match with # of groups');

% normalize responses 
switch(norm_method)
    case 'zscore'
		disp('Normalize ss_rsp by z-scoring ...');
        ss_rsp = zscore(ss_rsp, [], 1);
        % check outliers
        bOutlier = ss_rsp > 10;
    case 'none'
    otherwise
        error('Unknown norm_method: %s', norm_method);
end

%% Plot and analyze in the original state space
setfig(2,3, ['Population responses, norm. by ' norm_method]);
gna;
imagesc(1:size(ss_rsp,2), (1:size(ss_rsp,1))/sampling_rate, ss_rsp);
xlabel('Neuron'); ylabel('Time (tick)');
colorbar
stitle('%d timepoints * %d neurons', size(ss_rsp, 1), size(ss_rsp,2) );

gna;
% In the original dimension, compute pairwise distances between conditions for each timepoint 
for iTime = 1:size(rspTNC, 1)
	pairwise_dist(iTime, :) = pdist( squeeze(rspTNC(iTime, :, :))' , dist_method);
end
plot(pairwise_dist);
xlabel('Time (a.u.)'); ylabel('Distance');
stitle('Pairwise distance (%d pairs)', size(pairwise_dist, 2));
res.pairwise_dist = pairwise_dist;

% representation similarity analysis (RSA)
% compute RSA using time-varying data points. z-score is needed.
gna; 
mtx = [];
for iC = 1:nCond
	tmp = rspTNC(:, :, iC); 
	mtx(:, iC) = tmp(:);
end
rho = corr(mtx, 'type','Pearson','rows','pairwise');
rdm = 1 - rho;
imagesc(rdm); colorbar;
xlabel('gid'); ylabel('gid');
title('RDM (1-rho)');
res.rdm = rdm;

gna;
switch(dim_method)
	case 'pca'
		% perform PCA and compute coefficient for dim. reduction
		disp('Perform PCA...');
		[res.pca.coef, res.pca.score, res.pca.latent, res.pca.tsquared, res.pca.explained res.pca.mu] = pca(ss_rsp);
		tot_explained = cumsum(res.pca.explained);
		plot([res.pca.explained tot_explained], '-o')
		title('PCA, variance explained'); legend('Individual','Accumulated');
		xlabel('# of dimension'); ylabel('% varance explained');

		gna;
		imagesc(abs(res.pca.coef(:, 1:5)))
		colorbar;
		xlabel('PC'); ylabel('Original dimension');
		title('PCA, |coef|')
end

%% Plot and analyze in the low dimensional space
setfig(1,2, 'Trajectories in the low-D space');
gna;
% obtain TNC responses from the PCA results
% ps_score_3D = permute(reshape(res.pca.score, [nTime nCond nF]), [2 1 3])
ps_score_3D = reshape(res.pca.score, [nTime nCond nNeuron]);
% plot PCA trajectory
plot3_TCN(ps_score_3D(:, iCond, 1:3), 'grp_label', grp_label, 'view_info', 2, ...
    'traj_cmap', traj_cmap);
view(2);

end