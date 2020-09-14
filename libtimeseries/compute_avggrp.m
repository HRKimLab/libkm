function [psth] = compute_avggrp(x, rate_rsp, grp, varargin)
% test_diff, grp_lim, test_bin)
% make elements of grp to NaN if trigger or windows is not valid
% HRK 2016
if ~is_arg('grp'), grp = ones(size(rate_rsp, 1), 1); end;

test_diff = false;
test_timediff = false;
test_type = 'nonpar';   % 'nonpar', 'par'
btw_grp_test = 'unpaired' % unpaired: trial, paired: mpsths
grp_lim = 10;
test_bin = [];
x_base = [-1 0];      % timepoint range (e.g., [-1 0])
base_rsp = [];         % directly provide baseline rsp
resample_bin = 10;
roc = 0;
roc_base_grpid = [];   % compute auROC based on the specified two groups
valid_x_crit = 0.5; % criterion (trial ratio) to compute estimators at each time point (mean, std, sem, etc)

% array_rsp = [];  % do not use array_rsp. timestamp will be dropped due to subsampling

process_varargin(varargin);

assert(valid_x_crit < 1, 'valid_x_crit should be less than 1'); % b/c I do > below

[cmap nColor grpid gname gnumel] = grp2coloridx(grp, grp_lim);
n_trial = size(rate_rsp, 1);
    
% stats for drawing PSTH.
% mean can also be NaN if all column values are NaN
if size(rate_rsp,1) == 1 % grpstats does some stupid thing with row size is 1 (transpose it)
    mean_rsp  = rate_rsp;
    sem_rsp = zeros(size(rate_rsp)); 
    std_rsp = zeros(size(rate_rsp));
    numel_rsp = 1; 
else
%     [mean_rsp sem_rsp std_rsp numel_rsp num_nans] = grpstats(rate_rsp, grpid, {'mean','sem','std', 'numel', @nnan} );
      % grpstats iterate individual column using 'for' statement and using tryeval(). 
      % it is very inefficient and takes very long time. Just use built-in functions.
%     [mean_rsp std_rsp numel_rsp] = grpstats(rate_rsp, grpid, {'mean','std', 'numel'} );
    
    unq_gid = nonnan_unique(grpid); unq_gid = unq_gid(:); nG = numel(unq_gid);
    mean_rsp = NaN(nG, size(rate_rsp,2)); std_rsp = NaN(nG, size(rate_rsp,2));
    numel_rsp = NaN(nG, size(rate_rsp,2)); sem_rsp = NaN(nG, size(rate_rsp,2));
    valid_rsp = false(nG, size(rate_rsp,2));
    % iterate groups
    for iG = 1:nG
        % get the number of NaN trials at each time point
        numel_rsp(iG,:) = sum(~isnan(rate_rsp( grpid == unq_gid(iG),:) ), 1);
        % the number of trials in at each time point should be greater than
        % criterion to compute estimators. use '>' such that ignore 1/2 case.
        valid_rsp(iG,:) = numel_rsp(iG,:) > max( numel_rsp(iG,:) ) * valid_x_crit;
        % compute estimators in the valid range. Otherwise leave it as NaNs
        mean_rsp(iG, valid_rsp(iG,:) ) = nanmean(rate_rsp( grpid == unq_gid(iG), valid_rsp(iG,:) ), 1);
        std_rsp(iG, valid_rsp(iG,:) ) = nanstd(rate_rsp( grpid == unq_gid(iG), valid_rsp(iG,:) ), [], 1);
    end
    % compute sem based on std and numel
    sem_rsp = std_rsp ./ sqrt(numel_rsp);
    
%     assert(all(all(mean_rsp(~isnan(mean_rsp)) == mean_rsp2(~isnan(mean_rsp2)))));
%     assert(all(all(std_rsp(~isnan(std_rsp)) == std_rsp2(~isnan(std_rsp2)))));
%     assert(all(all(numel_rsp(~isnan(numel_rsp)) == numel_rsp2(~isnan(numel_rsp2))))); 

end

% get indice of groups in the increasing order of valid group size
[~, idx_sorted_by_num] = sort(sum(numel_rsp,2), 1, 'ascend');

%% now, perform statistical analysis for PSTH
% test difference in mean rates using ANOVA
pDiff = NaN(size(x));
pBaseDiff = NaN(nColor, length(x));
p2 = NaN(1,3);

nSkip = 1;
% if length > 100, test approx. 100 time points
% if length(x) > 100, nSkip = round( length(x) / 100 ); end

if is_arg('test_bin')
    nSkip = test_bin;
else
    % set nSkip to test every 0.1s
    nSkip = round(0.1/(x(2)-x(1)));
end

% I need to set the resample x to be multiples of 10 to later combine it easily.
% specifically, x should be matched in in adjust_psth_range()
% find the start index that is a multiple of 10
% resample_start_idx = find( mod(psth.x(1:10)*1000, 10) == 0 );
[~,iM] = min( abs( x(1:10)*1000 - round(x(1:10)*100) * 10 ) );
resample_start_idx = iM

if test_diff && any(any(~isnan(rate_rsp))) 
    % difference relative to baseline
    for iG = 1:nColor
        % use resample_start_idx instead of 1. Otherwise, p values will not
        % be sampled below
        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
            % compare response at x_base s with responses at each timepoint
            if ~isempty(base_rsp)
                base_rspG = base_rsp(grpid == iG);
            elseif numel(x_base) == 1
                base_rspG = rate_rsp(grpid == iG, x == x_base);
            elseif numel(x_base) == 2
                base_rspG = nanmean(rate_rsp(grpid == iG, x >= x_base(1) & x < x_base(2) ), 2);
            end
            % pairwise subtraction
            diff_vals = rate_rsp(grpid == iG, iC) - base_rspG;
            if nnum(diff_vals) > 0
                switch(test_type)
                    case 'nonpar'
                        pBaseDiff(iG, iC) = signrank(diff_vals);
                    case 'par'
                        [~, pBaseDiff(iG, iC)] = ttest(diff_vals);
                    otherwise
                        error('Unknown test_type: %s', test_type);
                end
            else
                pBaseDiff(iG, iC) = NaN;
            end
        end
    end
    
    switch(btw_grp_test)
        case 'unpaired'
            switch(test_type)
                case 'nonpar'
                    % difference between groups
                    if nColor == 2 % need to be changed using Wilcoxon test
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
                            if nnum(rate_rsp(grpid == 1,iC)) > 0 && nnum(rate_rsp(grpid==2,iC)) > 0
                                pDiff(iC) = ranksum(nonnans(rate_rsp(grpid==1,iC)), nonnans(rate_rsp(grpid==2,iC)));
                                %         pDiff(iC) = anova1(rate_rsp(:, iC), grpid,'off');
                            end
                        end
                    elseif nColor > 2
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
%                             pDiff(iC) = anova1(rate_rsp(:, iC), grpid,'off');
                            % Kruskal–Wallis one-way analysis of variance
                            pDiff = kruskalwallis(rate_rsp(:, iC), grpid, 'off');
                        end
                    end
                    
                case 'par'
                    % difference between groups
                    if nColor == 2 % need to be changed using Wilcoxon test
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
                            if nnum(rate_rsp(grpid == 1,iC)) > 0 && nnum(rate_rsp(grpid==2,iC)) > 0
%                                 pDiff(iC) = ranksum(nonnans(rate_rsp(grpid==1,iC)), nonnans(rate_rsp(grpid==2,iC)));
                                 pDiff(iC) = ttest2(nonnans(rate_rsp(grpid==1,iC)), nonnans(rate_rsp(grpid==2,iC)));
                            end
                        end
                    elseif nColor > 2
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
                            pDiff(iC) = anova1(rate_rsp(:, iC), grpid,'off');
                        end
                    end
                otherwise
                    error('Unknown test_type: %s', test_type);
            end
            
        case 'paired'
            switch(test_type)
                case 'nonpar'
                    % difference between groups
                    if nColor == 2 % need to be changed using Wilcoxon test
                        assert(nnz(grpid == 1) == nnz(grpid == 2), '# of groups should match in paired test');
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
                            if nnum(rate_rsp(grpid == 1,iC)) > 0 && nnum(rate_rsp(grpid==2,iC)) > 0
                                pDiff(iC) = signrank(nonnans(rate_rsp(grpid==1,iC)), nonnans(rate_rsp(grpid==2,iC)));
                                %         pDiff(iC) = anova1(rate_rsp(:, iC), grpid,'off');
                            end
                        end
                    elseif nColor > 2
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
                            % create a 2D array for paired comparison
                            rate_rsp_paired = NaN( numel(grpid)/max(grpid), max(grpid) );
                            for iG = 1:max(grpid)
                                bVG = grpid == iG;
                                assert(nnz(bVG) == numel(grpid)/max(grpid), 'array creation for paired test failed');
                                rate_rsp_paired(:, iG) = rate_rsp(bVG, iC);
                            end
%                             pDiff(iC) = anova_rm(rate_rsp_paired, 'off');
                              pDiff(iC) = friedman(rate_rsp_paired, 1, 'off');
                            warning('not tested thoroughly. needs to be confirmed');
                        end
                    end
                    
                case 'par'
                    % difference between groups
                    if nColor == 2 % need to be changed using Wilcoxon test
                        assert(nnz(grpid == 1) == nnz(grpid == 2), '# of groups should match in paired test');
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
                            if nnum(rate_rsp(grpid == 1,iC)) > 0 && nnum(rate_rsp(grpid==2,iC)) > 0
                                [~, pDiff(iC)] = ttest(nonnans(rate_rsp(grpid==1,iC)), nonnans(rate_rsp(grpid==2,iC)));
                                %         pDiff(iC) = anova1(rate_rsp(:, iC), grpid,'off');
                            end
                        end
                    elseif nColor > 2
                        for iC = resample_start_idx:nSkip:size(rate_rsp,2)
                            % create a 2D array for paired comparison
                            rate_rsp_paired = NaN( numel(grpid)/max(grpid), max(grpid) );
                            for iG = 1:max(grpid)
                                bVG = grpid == iG;
                                assert(nnz(bVG) == numel(grpid)/max(grpid), 'array creation for paired test failed');
                                rate_rsp_paired(:, iG) = rate_rsp(bVG, iC);
                            end
                            p_tmp = anova_rm(rate_rsp_paired, 'off');
                            pDiff(iC) = p_tmp(1);
                            warning('not tested thoroughly. needs to be confirmed');
                        end
                    end
                    
                otherwise
                    error('Unknown test_type: %s', test_type);
            end
            
        otherwise
            error('Unknown between-group test type: %s', btw_grp_test);
    end
    
end

if test_timediff && any(any(~isnan(rate_rsp)))
    % 3-way ANOVA adding trial duration, trial number as a second factor
    array_x = repmat(x, [size(rate_rsp,1) 1]);
    array_trialid = repmat((1:n_trial)', [1 size(x, 2)]);
    array_grp = repmat(grpid, [1 size(rate_rsp,2)]);
    r = rate_rsp(:,1:nSkip:end); a = array_x(:, 1:nSkip:end); b = array_grp(:, 1:nSkip:end); c = array_trialid(:, 1:nSkip:end);
    p2 = anovan(r(:), {a(:), b(:), c(:)},'display', 'off');
end % test_diff

% n_grp = grpstats(~isnan(trigger) & ~isnan(trial_start) & ~isnan(trial_end), grpid, {'sum'} );
n_grp = grpstats( ~isnan(grpid), grpid, {'sum'} );


psth.x = x;
psth.mean = mean_rsp;
psth.sem = sem_rsp;
psth.std = std_rsp;
psth.numel = numel_rsp;
psth.pDiff = pDiff;
psth.pBaseDiff = pBaseDiff;
psth.gname = cellfun(@str2num, gname);
psth.idx_sorted_by_num = idx_sorted_by_num;
psth.p2 = p2;
psth.gnumel = gnumel;

psth.rate_rsp = rate_rsp;
psth.grp = grp;
psth.grpid = grpid; % added 11/3/2019 HRK
psth.n_grp = n_grp;
psth.resample_bin = resample_bin;
% psth.array_rsp = array_rsp;  % do not use array_rsp. inaccurate timestamp

% resample psth to save memory and disk  8/14/2018 HRK
% iterate fields in the psth structure and resmaple
if resample_bin > 1 && diff(psth.x(1:2)) < 0.002 % only downsample when x is 1ms bin.
    assert(~isempty(resample_start_idx), 'cannot find resample_start_idx');

    % get the length of x
    nL = size(psth.x, 2);
    fn = fieldnames(psth);
    % subsample all fields that have the same size as x
    for iF = 1:numel(fn)
        if size(psth.(fn{iF}), 2) ~= nL
            continue;
        end
        psth.(fn{iF}) = psth.(fn{iF})(:, resample_start_idx:resample_bin:end);
    end
end

% make sure that x is multiple of 10 (I observed that occasionally x has
% tiny errors
x_interval = (1000/resample_bin);
psth.x = round(psth.x * x_interval) / x_interval;

% do ROC analysis after resampling because it takes lots of time..
if roc
    roc = NaN(nColor, length(psth.x) );
    for iG = 1:nColor
        % compare response at x_base s with responses at each timepoint
        if ~isempty(base_rsp)
            % use baseline in each group
%             base_rspG = base_rsp(grpid == iG);
            % use all baseline 
            base_rspG = base_rsp;
        elseif numel(x_base) == 1
            % per-group baseline
%             base_rspG = psth.rate_rsp(grpid == iG, psth.x == x_base);
            % combined baseline 
              base_rspG = psth.rate_rsp(:, psth.x == x_base);
        elseif numel(x_base) == 2
            % do not take mean for ROC. just take all data points
            % per-group baseline
%             base_rspG = psth.rate_rsp(grpid == iG, psth.x >= x_base(1) & psth.x < x_base(2) );
            % combined baseline
            base_rspG = psth.rate_rsp(:, psth.x >= x_base(1) & psth.x < x_base(2) );
            base_rspG = base_rspG(:);
        end
        
        for iC = 1:size(psth.rate_rsp,2)
            % ROC comparison between groups
            if ~isempty(roc_base_grpid)
                base_rspG = psth.rate_rsp(grpid == roc_base_grpid, iC);
            end
            roc(iG, iC) = auROC(psth.rate_rsp(grpid == iG, iC), base_rspG );
        end
    end
else
    roc = [];
end
psth.roc = roc;