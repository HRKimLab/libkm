function [ss_rsp rspTCN] = analzye_state_space(rspTCN, varargin)
% ANALYZE_STATE_SPACE basic state space analysis
% 
%  
% TODO: incorporate plot_timecourseMD
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
traj_cmap = '';          % color map for each condition
iCond = [];              % conditions indice for visualization
neuron_label = [];
grp_label = [];
animation = 0;
sampling_rate = 100; % 100Hz (10ms bin)

process_varargin(varargin);

nTime = size(rspTCN, 1);
nCond = size(rspTCN, 2);
nNeuron = size(rspTCN, 3);

% get ss response
ss_rsp = TCN2ss(rspTCN);

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
        ss_rsp = zscore(ss_rsp, [], 1);
        % check outliers
        bOutlier = ss_rsp > 10;
    case 'none'
    otherwise
        error('Unknown norm_method: %s', norm_method);
end

setfig(2,2, ['Population responses, norm. by ' norm_method]);
gna;
imagesc(1:size(ss_rsp,2), (1:size(ss_rsp,1))/sampling_rate, ss_rsp);
xlabel('Neuron'); ylabel('Time (tick)');
colorbar
stitle('%d timepoints * %d neurons', size(ss_rsp, 1), size(ss_rsp,2) );

gna;
% perform PCA
disp('Perform PCA...');
[pc_coef, pc_score, pc_latent, pc_tsquared, pc_explained pc_mu] = pca(ss_rsp);
tot_explained = cumsum(pc_explained);
plot([pc_explained tot_explained], '-o')
title('Variance explained'); legend('Individual','Accumulated');

setfig(1,2);
gna;
% obtain TCN responses from the PCA results
% ps_score_3D = permute(reshape(pc_score, [nTime nCond nF]), [2 1 3])
ps_score_3D = reshape(pc_score, [nTime nCond nNeuron]);

% plot PCA trajectory
plot3_TCN(ps_score_3D(:, iCond, 1:3), 'grp_label', grp_label, 'view_info', 2, ...
    'traj_cmap', traj_cmap);
view(2);

end