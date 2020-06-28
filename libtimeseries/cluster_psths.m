function ret = cluster_psths(comb_psth, varargin)
% perform dimensionality reduction and cluster population psths
% wrapper function to call pre-existing clustering routine
% 2019 HRK

nclust = 3;
ndim = 10;
ndim_coef_disp = 5; % do not need to show all;
ndim_coef_disp_smooth_win = 5; % smooth windows for coef
dimred = 'pca';  % pca, nnmf
x_refs = [];
x_label = '';
t_sne = 0;
auto_crop_x = 1;        % crop x to remove NaNs
tutorial = 0;   % make a simple, tutorial version data
preproc = 'none';
test_diff = 0;
use_parallel = 1; % 1: use default parallel processing toolbox. delete 2: do not delete
border = [];        % border for top level subgroups
border2 = [];       % border 2nd-level subgroups
image_cmap = '';
cl = [];            % color range for imagesc
% methods goes from more conventional to more experimental. 
cluster_methods = 'kmeans';   % This is just a keyword to decide where to stop

process_varargin(varargin);

psth_type = class(comb_psth)
switch(psth_type)
    case 'struct'
        if isfield(comb_psth, 'x')
            pop_data = comb_psth.rate_rsp;
            pop_data_x = comb_psth.x;
            bVGrp = ~isnan(comb_psth.grp);
        else
            error('struct but not psth');
        end
    case 'double' 
        pop_data = comb_psth;
        pop_data_x = 1:size(pop_data, 2);
        bVGrp = true(size(pop_data,1), 1);
    otherwise
        error('Unkonw type: %s', psth_type)
end

nN = size(pop_data, 1);
if ndim > nN
    warning('cluster_psth: ndim > nN. reduce it to nN.');
    ndim = nN;
end

if test_diff == 1
    test_diff = 200;
end
if tutorial 
    % pick sample neurons
    iSamples = randsample( nN, tutorial);
    % assign groups that resembles activity of sample neurons
    neuron_grp = randsample( tutorial, nN, true);
    % fake toy dataset
    tut_data = zeros(size(pop_data));
    % generate a fake data
    for iiS = 1:numel(iSamples)
        % make variations by multiplying a random gain to the sample
        % neurons' activity
        bG = neuron_grp == iiS;
        tut_data(bG,:) = tut_data(bG,:) + ...
            randn([nnz(bG) 1]) * pop_data(iSamples(iiS), :);
    end
    % add some noise
    tut_data = tut_data + randn(size(tut_data)) * 0.2;
    % assign it to pop_data
    pop_data = tut_data;
end

% NaN screw up PCA. remove them.
if auto_crop_x
    bVX = all(~isnan(pop_data), 1);
    pop_data = pop_data(:, bVX);
    pop_data_x = pop_data_x(bVX);
    
    if ~isempty(border)
        i_border = find_closest( border, pop_data_x );
    else, i_border = []; end
    if ~isempty(border2)
        i_border2 = find_closest( border2, pop_data_x );
    else, i_border2 = []; end
    
    fprintf(1, 'remove %d data points that contain NaNs => %d valid data points\n', nnz(~bVX), nnz(bVX));
end

bV = bVGrp & ~any(isnan(pop_data), 2);
fprintf(1, 'exclude %d/%d neurons whose grp or data contain NaN\n', nnz(~bV), numel(bV));
pop_data = pop_data(bV,:);

% figure;
% imagesc(pop_data); 
% colorbar; colormap gray

switch(preproc)
    case 'zscore'
        pop_data = zscore(pop_data);
    case 'none'
    otherwise
        error('Unknown norm method: %s', preproc)
end

if ndim > size(pop_data, 1)
    ndim = size(pop_data, 1);
end
%% reduce dimensionality
% n-by-p data matrix X. Rows of X correspond to observations and columns 
% correspond to variables. The coefficient matrix is p-by-p.
% Here, pop_data is [# neuron * # of timepoint], not the other.
% because we are interested in explaining variance across neurons. 
% so single neurons becomse different observations, and individual timempoint
% becomes different parameters.
switch(dimred)
    case {'pca','PCA'} % principal component analysis
        [pc_coef, pc_score, pc_latent, pc_tsquared, pc_explained pc_mu] = pca(pop_data);
        tot_explained = cumsum(pc_explained);
    case {'nnmf','NNMF'} % non-negative matrix factorization   
        opt = statset('MaxIter', 3000, 'Display', 'final');
        
        [W H D] = nnmf(pop_data, ndim, 'replicates', 5, 'options',opt,'algorithm','mult');
        pc_coef = H'; 
        pc_score = W;
        for clust = 1:ndim
            % results are different 
%             est_popdata = W(:, 1:clust) * H(1:clust,:);
            [W H D] = nnmf(pop_data, clust, 'replicates', 5, 'options',opt,'algorithm','mult');
            est_popdata = W * H;
            gof(clust) = compute_gof(pop_data(:), est_popdata(:));
            tot_explained(clust) = gof(clust).rsquare * 100;
            if clust == 1
                pc_explained(clust) = gof(clust).rsquare * 100;
            else
                pc_explained(clust) = (gof(clust).rsquare-gof(clust-1).rsquare) * 100;
            end
        end
    case 'sparse_nnmf'
        [x1 infos] = nmf_sparse_mu(pop_data, ndim, []);
        W = x1.W;
        H = x1.H;
        pc_coef = H'; 
        pc_score = W;
end

% plot dim. reduction results
p = setpanel(2, 2, ['Dim. reduction using ' dimred ', nDim = ' num2str(ndim)], 1);
ax = p.gna;
% imagesc is not doing accurate job at all in plotting x.
% imagesc ignores s and just linspace x axis
% imagesc(pop_data_x, 1:size(pop_data, 1), pop_data); xlim(minmax(pop_data_x)); 
imagesc(pop_data); xlim([0.5 size(pop_data, 2)+0.5]); colorbar;
% draw refs and borders
draw_refs(0, x_refs, 0);
draw_refs(0, i_border, NaN);
set(draw_refs(0, i_border2, NaN), 'linestyle', ':');
ylim([0.5 size(pop_data, 1)+0.5]);
axis ij;
ylabel('Obs. #');
stitle('%d obs * %d variables data', size(pop_data, 1), size(pop_data, 2) );
% apply colormap and clim
if ~isempty(image_cmap), colormap(image_cmap); end
if ~isempty(cl), set(gca, 'clim', cl); end

% change ref color if needed
switch(image_cmap)
    case 'yellowblue', set(findobj(gca,'tag','ref'), 'color', 'w')
end

ax(2) = p.gna;
% pop_data_x causes problems in imagesc (see above). ignore x scale
% plot(pop_data_x, pc_coef(:,1:nclust)); xlim(minmax(pop_data_x));
if ~isempty(ndim_coef_disp_smooth_win) && ndim_coef_disp_smooth_win > 0
    sm_pc_coef = conv2(pc_coef(:,1:ndim_coef_disp), ones(ndim_coef_disp_smooth_win , 1)/ndim_coef_disp_smooth_win, 'same');
end
plot(sm_pc_coef); 
xlim([0.5 size(pop_data, 2)+0.5]);
% draw refs and borders
draw_refs(0, x_refs, 0);
draw_refs(0, i_border, NaN);
set(draw_refs(0, i_border2, NaN), 'linestyle', ':');
xlabel(x_label);
legend(arrayfun(@(x) sprintf('PC%d', x), 1:ndim_coef_disp, 'un', false)); legend boxoff
stitle('PCs, nDim = %d', ndim);
% match axis location
hCB = colorbar; set(hCB,'visible','off');
linkaxes_ext(ax, 'x');

p.gna;
est_popdata = pc_score(:, 1:ndim) * pc_coef(:, 1:ndim)';
imagesc(est_popdata); colorbar;
axis ij;
xlim([0.5 size(est_popdata,2)+0.5]); ylim([0.5 size(est_popdata, 1)+0.5]);
stitle('Reconstructed data using nDim = %d', ndim);
% apply colormap and clim
if ~isempty(image_cmap), colormap(image_cmap); end
% reconstructed prediction is not the same scale. need to fix.
% if ~isempty(cl), set(gca, 'clim', cl); end  
% change ref color if needed
switch(image_cmap)
    case 'yellowblue', set(findobj(gca,'tag','ref'), 'color', 'w')
end

p.gna;
pc_explained = pc_explained(:); tot_explained = tot_explained(:);
plot([pc_explained(1:min([end 10])) tot_explained(1:min([end 10]))], '-o');
xlabel('PC'); ylabel('% variance');
legend('Ind','Accum'); legend boxoff;
title('% variance explained');
% match axis location
hCB = colorbar; set(hCB,'visible','off');

ret.pc_score = pc_score;
ret.pc_coef = pc_coef;
%% k-means clustering based on PCs
% Kmeans clustering on data projections onto PCs
% perform on pc_score
% One of the deficiencies of k-means clustering is that the quality of the
% clustering varies based on the initial seeds.  kmeansinit() will generate
% a set of seeds to appropriately spread the clusters.  
% See 'help kmeansinit()' for details
data = pc_score;
seeds = kmeansinit(data, nclust);
cid_kmeans = kmeans(pc_score, nclust, 'Start',seeds);
% an alternative you can try with your data is 
% cid_kmeans = kmeans(pc_score,nclust, 'Replicates',5);

% %% relabelClusters(): A utility to help organize the order of the cluster
% % labels to match your own preferred order.  e.g., Type 1-3 had specific 
% % meanings to us so we tried to make cid_kmeans match as closely as
% % possible.
% 
% %   RELABELCLUSTERS: newlabel = relabelClusters(clust,truelabel)
% %   This function chooses numerical labels for the clustering in the vector
% %   clust so that it best matches the labels in truelabel.
% %   e.g., if clust is  [3 3 3 2 1 2 2 1 1 1 1 1] 
% %    and truelabel is  [1 1 1 2 2 2 2 3 3 3 3 3]
% %    then this returns [1 1 1 2 3 2 2 3 3 3 3 3]
% %   As currently written it works with numerical labels starting from 1.
% [cid_kmeans jeremiahType relabelClusters(cid_kmeans, jeremiahType)] %#ok<NOPTS>
% cid_kmeans = relabelClusters(cid_kmeans, jeremiahType);
% matchrate = sum(cid_kmeans==jeremiahType)/length(jeremiahType) %#ok<NOPTS>

setfig(2,3, ['k-means clustering based on PC scores, nclust = ' num2str(nclust)]);
gna;
% set color and markersize
if nN > 1000, markersize = 10;
elseif nN > 500, markersize = 13;
elseif nN > 100, markersize = 15;
elseif nN > 50, markersize = 20;
else, markersize = 20;
end
cmap = get_cmap(max(cid_kmeans));
scatter(pc_score(:,1), pc_score(:,2), markersize, cmap(cid_kmeans,:), 'filled');
title('Projection on a 2D plane');
xlabel('PC1'); ylabel('PC2');
gna;
scatter3(pc_score(:,1), pc_score(:,2), pc_score(:,3), markersize, cmap(cid_kmeans,:), 'filled');
title('Projection on a 3D space');
xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
gna;
[~, iS] = sort(cid_kmeans);
plot_continuous_array(1:size(pop_data, 2), pop_data(iS, :), cid_kmeans(iS), false, gca);
% draw refs and borders
draw_refs(0, x_refs, 0);
draw_refs(0, i_border, NaN);
set(draw_refs(0, i_border2, NaN), 'linestyle', ':');
% apply colormap and clim
if ~isempty(image_cmap), colormap(image_cmap); end
if ~isempty(cl), set(gca, 'clim', cl); end
% change ref color if needed
switch(image_cmap)
    case 'yellowblue', set(findobj(gca,'tag','ref'), 'color', 'w')
end

gna;
this_psth.x = 1:size(pop_data, 2);
this_psth.rate_rsp = pop_data(iS, :);
this_psth.grp = cid_kmeans(iS);
ax = plot_timecourse('stream', [], [], [], [], [], 'use_this_psth', this_psth);
axes(ax(2));
% draw refs and borders
draw_refs(0, x_refs, 0);
draw_refs(0, i_border, NaN);
set(draw_refs(0, i_border2, NaN), 'linestyle', ':');
% apply colormap and clim
if ~isempty(image_cmap), colormap(image_cmap); end
if ~isempty(cl), set(gca, 'clim', cl); end
% change ref color if needed
switch(image_cmap)
    case 'yellowblue', set(findobj(gca,'tag','ref'), 'color', 'w')
end

gna;
[gnumel gname] = grpstats(ones(size(cid_kmeans)), cid_kmeans, {'sum', 'gname'});
assert(numel(gnumel) == max(cid_kmeans))
bar(gnumel);
xlabel('Cluster ID');
ylabel('Frequency');

if test_diff && use_parallel > 0
    try
        pPool = gcp;
    catch
        disp('Parallel processing toolbox is missing. skip testing sig. diff');
        disp('use option use_parallel == 0 if you want to run w/o the toolbox');
        test_diff = 0;
    end
end

if test_diff
    % start parallel processing pool
    if use_parallel 
        pPool = gcp;
    end
    if any(any(isnan(pc_score)))
        warning('NaN found in pc_score');
        keyboard
    end
    % significant test
    pPair = NaN(nclust, nclust);
    mc_sig = [];     % for plotting
    for iR = 1:nclust
        for iC = 1:nclust
            if iR > iC, continue; end
            fprintf('testing sig. of cluster %d and %d ', iR, iC);
            [~, pPair(iR, iC)] = clusterPairSigTest(pc_score(cid_kmeans == iR,:), ...
                pc_score(cid_kmeans == iC, :), test_diff);
            fprintf('P = %.3f\n', pPair(iR, iC) );
            if iR ~= iC
                mc_sig = [mc_sig; iR iC pPair(iR,iC) < 0.05];
            end
        end
    end
    if use_parallel ~= 2
        % delete parallel pool
        delete(pPool);
    end
    ret.pPair = pPair;
    
    yl = get(gca,'ylim');
    hL = disp_multiple_comparison_results(mc_sig, [0 yl(2) * 1.5]);  
    set(hL, 'markersize', 5);
    atitle('Sig. test');
end



ret.cid_kmeans = cid_kmeans;

if strcmp(cluster_methods, 'kmeans')
    return;
end
%% hierarchical cluster tree
figure;
fig_title('hierarchical cluster tree');
subplot(1,3,3);
myTree = linkage(pop_data,'complete','euclidean');
thresh = myTree(end-nclust+2,3); %this line is a hack to figure out the threshold so you get nclust colors 
% dendrogram(myTree,0,'labels',num2str(jeremiahType),'ColorThreshold',thresh);
[hout, T, perm] = dendrogram(myTree,0,'ColorThreshold',thresh, 'orientation', 'right');
cid_tree = cluster(myTree, 'MaxClust', nclust );
set(gca, 'yticklabel',[], 'xtick',[], 'xticklabel', []);
subplot(1,3,[1 2]);
imagesc(1:size(pop_data, 2), 1:size(pop_data, 1), flipud(pop_data(perm,:)));
% draw_refs(0, x_refs, NaN);
draw_refs(0, i_border, NaN);
set(draw_refs(0, i_border2, NaN), 'linestyle', ':');
xlabel(x_label);
colorbar('westoutside');
% apply colormap and clim
if ~isempty(image_cmap), colormap(image_cmap); end
if ~isempty(cl), set(gca, 'clim', cl); end
stitle('N = %d, sb cluster id, nclust = %d', nnz(bV), nclust);

% change ref color if needed
switch(image_cmap)
    case 'yellowblue', set(findobj(gca,'tag','ref'), 'color', 'w')
end
%% plot t-SNE results sorted by cluters based on hierarchical cluster tree
if t_sne
    setfig(2,2, 't-SNE');
    gna;
    x = tsne(pop_data, 'Algorithm','exact','Distance','mahalanobis', 'NumPCAComponents', min([20 size(pop_data, 2)]) );
    gscatter(x(:,1), x(:,2), cid_tree);
    title('t-SNE on 2D');
    gna;
    x = tsne(pop_data, 'NumDimensions', 3);
    scatter3(x(:,1), x(:,2), x(:,3), [], cid_tree);
    title('t-SNE on 3D');
end