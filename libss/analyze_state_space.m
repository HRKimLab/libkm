function [res ss_rsp rspTCN] = analzye_state_space(rspTCN, varargin)
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
dist_method = 'euclidean'; % method for pairwise distance
dim_method = 'pca';		  % unsupervised dim. reduction method
decode_method = '';		  % supervised decoding method (TODO)
traj_cmap = '';          % color map for each condition
iCond = [];              % conditions indice for visualization
neuron_label = [];
animation = 0;
sampling_rate = 100; % 100Hz (10ms bin)
tick_Time = [];
x_base = [-1 0];	% baseline time window
rate_rsp = [];		% trial-to-trial responses [Time Neuron Trial]
ginfo = [];
grpid = [];			% in case we do not use ginfo
grp_label = [];		% in case we do not use ginfo
show_individual = 0;

process_varargin(varargin);

nTime = size(rspTCN, 1);
nCond = size(rspTCN, 2);
nNeuron = size(rspTCN, 3);

if ~isempty(ginfo)
	grpid = ginfo.grp_idx;
	grp_label = ginfo.unq_grp_label;
	assert(nunique(grpid) == numel(grp_label), '# of grpid (%d) does not match with # of grp_label (%d)', ...
		nunique(grpid), numel(grp_label) );
else
	grp_label = arrayfun(@(x) sprintf('G%d', x), 1:nCond, 'un',false);
end

if is_arg('tick_Time')
	assert(numel(tick_Time) == nTime, '# of time ticks (%d) does not match with # of rows (%d) in TCN', ...
		numel(tick_Time) , nTime);
else
	tick_Time = (1:nTime) / sampling_rate;
end

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
		disp('Normalize ss_rsp by z-scoring ...');
        [ss_rsp, mu, sigma] = zscore(ss_rsp, [], 1);
		
		% re-compute rspTCN (normailized across condition) from the normalized responses
		rspTCN = ss2TCN(ss_rsp, [nTime, nCond, nNeuron] );
		
		if ~isempty(rate_rsp)
			% try to normalize rate_rsp similarly. I may need to use same mean and
			% variance of above.
			sigma0 = sigma;
			sigma0(sigma0==0) = 1;
% 			rate_rsp = bsxfun(@minus,rate_rsp, mu);
			
			% for confirmation
			% mu == mean(mean(rate_rsp, 1), 3)
			
% 			rate_rsp = bsxfun(@rdivide, rate_rsp, sigma0);
% 			rate_rsp = bsxfun(@rdivide, rate_rsp, std(rate_rsp, [], 1) );
			
		end
		
% 		rate_rsp = zscore(rate_rsp , [], 1);
        % check outliers
        bOutlier = ss_rsp > 10;
    case 'none'
    otherwise
        error('Unknown norm_method: %s', norm_method);
end

%% Plot and analyze in the original state space
setfig(3,3, ['Population responses, norm. by ' norm_method]);
gna; gna; subplot(3,3, [1 2]);
% note that image does not check # of elements between 2D array and x, y.
% it just assign x axis range where the image is located on the x and y
% axis.
if nCond == 1
	% show exact time tick
	imagesc(tick_Time, 1:size(ss_rsp,2), ss_rsp');
	% draw reference line
	if tick_Time(1) * tick_Time(end) < 0, draw_refs(0, 0, NaN); xlim([tick_Time(1) tick_Time(end)]); end;
	if isempty(tick_Time), xlabel('Time');
	else, xlabel('Time (s)'); end
	
	imagesc(tick_Time, 1:size(ss_rsp,2), ss_rsp');
else % multiple conditions. Time is not accurate since it is concatenated.
	imagesc(1:size(ss_rsp, 1), 1:size(ss_rsp,2), ss_rsp');
	% separate between conditions
	set(draw_refs(0, (1:nCond) * nTime, NaN),'linestyle','-');
	% draw stim. onset lines
	stim_on = find(repmat(tick_Time, [1 nCond]) == 0);
	set(draw_refs(0, stim_on, NaN),'linestyle', ':');
end
ylabel('Neuron'); 
colorbar
stitle('%d timepoints, %d neurons', size(ss_rsp, 1), size(ss_rsp,2) );

% In the original dimension, compute pairwise distances between conditions for each timepoint 
gna;
fprintf(1, 'Compute pairwise distance between conditions ...');
for iTime = 1:size(rspTCN, 1)
	pairwise_dist(iTime, :) = pdist( permute(rspTCN(iTime, :, :), [2 3 1]) , dist_method); 
end
fprintf(1, ' done.\n');

if ~isempty(pairwise_dist)
plot(tick_Time, pairwise_dist);
end
% draw reference line
if tick_Time(1) * tick_Time(end) < 0, draw_refs(0, 0, NaN); xlim([tick_Time(1) tick_Time(end)]); end;
if isempty(tick_Time), 	xlabel('Time'); else, xlabel('Time (s)'); end
ylabel('Distance');
stitle('Pairwise distance (%d pairs)', size(pairwise_dist, 2));

% baseline time window
b_base_win = tick_Time >= x_base(1) & tick_Time < x_base(2);

% compute Euclidean distnace
eucl_dist = NaN(nTime, 1, nCond);
m_base = mean(rspTCN(b_base_win, :, :), 1);
v_base_diff = bsxfun(@minus, rspTCN, m_base);	
% for iC = 1:nCond
	eucl_dist = sqrt(sum(v_base_diff.^2, 3));
% end

if ~isempty(rate_rsp) && show_individual
	eucl_dist_trial = NaN(nTime, 1, size(rate_rsp, 3) );
 	m_base_trial = nanmean(nanmean(rate_rsp(b_base_win, :, :), 1), 3);
	v_base_diff = bsxfun(@minus, rate_rsp, permute(m_base_trial , [1 2 3]) );
% 	for iT = 1:size(rate_rsp, 3)
		eucl_dist_trial = sqrt(sum(v_base_diff.^2, 2));
% 	end
else
	eucl_dist_trial = [];
end

gna;
if ~isempty(eucl_dist_trial)
	plot(tick_Time, permute(eucl_dist_trial, [1 3 2]), 'color', [.5 .5 .5]);
	hold on;
	% average of trial-to-trial distance
	plot(tick_Time, nanmean(permute(eucl_dist_trial, [1 3 2]), 2) , 'color', 'r');
end
hold on; % in case trial-to-trial data is not plotted
for iC = 1:nCond
	plot(tick_Time, eucl_dist(:, iC), 'color', traj_cmap(iC,:), 'linewidth', 3);
end
% draw reference line
if tick_Time(1) * tick_Time(end) < 0, draw_refs(0, 0, NaN); xlim([tick_Time(1) tick_Time(end)]); end;

if isempty(tick_Time), 	xlabel('Time'); else, xlabel('Time (s)'); end
ylabel('Distance');
title('Euclidean dist.');
legend(grp_label);

hold off;

% compute Mahalanobis distance
fprintf(1, 'Compute Mahalanobis distance from the baseline for each condition ...');
mahal_dist = NaN(nTime, 1, nCond);
for iC = 1:nCond
	% ss_base : [Time Neuron Trials]
	ss_base_tmp = rate_rsp(b_base_win, :, grpid == iC);
	ss_base = [];
	% stack trials vertically in column [(n_time * n_trials) x n_neuron]
	for iTr = 1:size(ss_base_tmp, 3)
		ss_base = [ss_base; ss_base_tmp(:, :, iTr)];
	end
	% to estimate Gaussian distribution, fitgmdist requires that
	% # of observations is greater than # of dimensions.
	if size(ss_base, 1) <= size(ss_base, 2)
		fprintf(1, '# of trials (%d) in group %d is less than # of dim. (%d). Skip computing Mahalanobis distance (put NaN)\n', ...
			size(ss_base, 1), iC, size(ss_base, 2));
		continue;
	end
	% fit Gaussian model with one Gaussian. 
	gm = fitgmdist(ss_base, 1, 'RegularizationValue', 0.0001);
% 	gm = fitgmdist(ss_base, 1, 'RegularizationValue', 0.001);
% 	gm = fitgmdist(ss_base, 1, 'RegularizationValue', 0.01);
% 	for iT = 1:nTime
% 		mahal_dist(iT, 1, iC) = mahal(gm, squeeze( rspTCN(iT, iC, :) )' );
% 	end	
	% fast version
	mahal_dist(:, 1, iC) = mahal(gm, permute( rspTCN(:, iC, :), [1 3 2]));
end
fprintf(1, ' done.\n');

gna;
plot(tick_Time, squeeze(mahal_dist));
% draw reference line
if tick_Time(1) * tick_Time(end) < 0, draw_refs(0, 0, NaN); xlim([tick_Time(1) tick_Time(end)]); end;

if isempty(tick_Time), 	xlabel('Time'); else, xlabel('Time (s)'); end
ylabel('Distance');
title('Mahalanobis dist.');

% representation similarity analysis (RSA)
% compute RSA using time-varying data points. z-score is needed.
gna; 
mtx = [];
for iC = 1:nCond
	tmp = rspTCN(:, iC, :); 
	mtx(:, iC) = tmp(:);
end
rho = corr(mtx, 'type','Pearson','rows','pairwise');
rdm = 1 - rho;
imagesc(rdm); colorbar;
xlabel('gid'); ylabel('gid');
title('RDM (1-rho)');


gna;
switch(dim_method)
	case 'pca'
		% perform PCA and compute coefficient for dim. reduction
		disp('Perform PCA ...');
		[res.pca.coef, res.pca.score, res.pca.latent, res.pca.tsquared, res.pca.explained res.pca.mu] = pca(ss_rsp);
		tot_explained = cumsum(res.pca.explained);
		plot([res.pca.explained tot_explained], '-o');
		title('PCA, variance explained'); legend('Individual','Accumulated');
		xlabel('# of dimension'); ylabel('% varance explained');

		gna;
		imagesc(abs(res.pca.coef(:, 1:min([5 end]))));
		colorbar;
		xlabel('PC'); ylabel('Original dimension');
		title('PCA, |coef|');
		
		[~, iS] = sort(abs(res.pca.coef(:, 1)),'descend');
		fprintf(1, 'Neuron ids with largest |coef|: %s\n', sprintf('%d ', iS(1:min([end 5]))) );
end

%% Plot and analyze in the low dimensional space
setfig(1,1, 'Trajectories in the low-D space');
gna;
% obtain TCN responses from the PCA results
% ps_score_3D = permute(reshape(res.pca.score, [nTime nCond nF]), [2 1 3])
% if the # of observation is less than # of dimension -
% (i.e., size(ss_rsp, 1) < size(ss_rsp, 2) ), PCA scores will have lower
% dimension than nNeuron. To deal with this, let's leave the last dimention
% undecided.
ps_score_3D = reshape(res.pca.score, nTime, nCond, []);
% ps_score_3D = reshape(res.pca.score, [nTime nCond nNeuron]);

% plot PCA trajectory
plot3_TCN(ps_score_3D(:, iCond, 1:3), 'grp_label', grp_label, 'view_info', 2, ...
    'traj_cmap', traj_cmap, 'tick_Time', tick_Time);
view(2);

hold on;
if show_individual && ~isempty(rate_rsp);
	for iT = 1:10 %size(rate_rsp, 3)
		score_individual(:,:,iT) = rate_rsp(:,:,iT) * res.pca.coef;
		h_traj(iT) = plot3( score_individual(:, 1, iT), score_individual(:, 2, iT), score_individual(:, 3, iT));
	end
end
hold off;

end