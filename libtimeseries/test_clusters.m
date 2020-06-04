function cl = test_clusters(comb_psth, varargin)
% iteratively call k-means clustering with increasing n_cluster
% 2020 HRK

max_nclust = 5;
test_diff = 300;
use_parallel = 2; % 1: use default parallel processing toolbox. delete 2: do not delete
preproc = 'none';
border = [];
border2 = [];
dimred = 'pca';

process_varargin(varargin);

for nclust = 2:max_nclust
   cl(nclust) = cluster_psths(comb_psth, 'nclust', nclust, 'auto_crop_x', 1, ...
    'preproc', preproc, 'test_diff', test_diff, 'use_parallel', use_parallel, ...
    'border', border, 'border2', border2, 'dimred', dimred); 
end