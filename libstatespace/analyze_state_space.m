function [ss_rsp rspTCN] = analzye_state_space(rspTCN, varargin)
% basic state space analysis
% assuming that any psth.mean is not NaN and homogeneous
% 2022 HRK

norm_method = 'zscore';  % normalize data
traj_cmap = '';    % color map for trajectories
iCond = [];
neuron_label = [];
grp_label = [];
animation = 0;
sampling_rate = 100; % 100Hz (10ms bin)

process_varargin(varargin);

nTime = size(rspTCN, 1);
nCond = size(rspTCN, 2);
nNeuron = size(rspTCN, 3);

ss_rsp = TCN2ss(rspTCN);

if isempty(iCond)
    iCond = 1:nCond;
end

assert(isempty(grp_label) || numel(grp_label) == nCond, ...
    '# of grp_label should match with # of groups');
assert(isempty(traj_cmap) || size(traj_cmap, 1) == nCond, ...
    '# of traj_cmap should match with # of groups');

% normalize responses 
switch(norm_method)
    case 'zscore'
        ss_rsp = zscore(ss_rsp,[],1);
        % check outliers
        bOutlier = ss_rsp > 10;
        
    otherwise
end

setfig(2,2, 'state space analysis');
gna;
imagesc(1:size(ss_rsp,2), (1:size(ss_rsp,1))/sampling_rate, ss_rsp);
colorbar
stitle('%d timepoints * %d neurons', size(ss_rsp, 1), size(ss_rsp,2) );

gna;
% perform PCA
[pc_coef, pc_score, pc_latent, pc_tsquared, pc_explained pc_mu] = pca(ss_rsp);
tot_explained = cumsum(pc_explained);
plot([pc_explained tot_explained], '-o')
title('Variance explained'); legend('Individual','Accumulated');

setfig(1,2);
gna;
% ps_score_3D = permute(reshape(pc_score, [nTime nCond nF]), [2 1 3])
ps_score_3D = reshape(pc_score, [nTime nCond nNeuron]);
% plot trajectory
plot3_TCN(ps_score_3D(:, iCond, :), 'grp_label', grp_label, 'view_info', 2, ...
    'traj_cmap', traj_cmap);
view(2);

gna;
set(gca,'colororder', traj_cmap); 
set(gca,'nextplot','replacechild')
% plot trajectory
plot_TCN(ps_score_3D(:, iCond, :), 'grp_label', grp_label);

end