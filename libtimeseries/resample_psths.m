function [ax pop_psth cMissing] = resample_psths(stPSTH, varargin)
% resample trials from single trials of individual neurons
% 2018 HRK

n_grps = [];
func = [];
event_header = {};
ax = [];
grp_xlim = [];
shuffled_pick = 0;
test_diff = 0;
debug = 0;
estimator = 'zscore';
base_sub_win = [];
split_v = [.7 .3];

process_varargin(varargin);

if ~is_arg('func')
    func = @nansum;
end
fn = fieldnames(stPSTH);
nF = numel(fn);
all_rsp = []; all_grp = []; x = [];
cMissing = {};
% detrmine x and check group #
for iF = 1:nF
    % check x range of individual psths
    if ~isempty(grp_xlim)
       gxl = minmax(grp_xlim(:));
       pxl = minmax(stPSTH.(fn{iF}).x);
       if pxl(1) <= gxl(1) && pxl(2) >= gxl(2)
       else
           warning('%s range (%s) is not a subset of grp_xlim(%.1f %.1f)', fn{iF}, num2str(pxl), gxl(1), gxl(2) );
       end
    end
    % get x intersect of Xs
    if isempty(x)
        x = stPSTH.(fn{iF}).x;
    else
        x = intersect(x, stPSTH.(fn{iF}).x);
    end
    % check group #
    if numel(stPSTH.(fn{iF}).gname) ~= numel(n_grps)
        error('# of groups in psth %s (%d) is not same as argument (%d)', ...
            fn{iF}, numel(stPSTH.(fn{iF}).gname), numel(n_grps) );
    end
    % check if mean has NaN in the x range
    if ~isempty(grp_xlim)
        nG = size( stPSTH.(fn{iF}).mean, 1);
        bValid = false(size( stPSTH.(fn{iF}).mean ) );
        for iG = 1:nG
            bValid(iG, :) = stPSTH.(fn{iF}).x >= grp_xlim(iG, 1) & stPSTH.(fn{iF}).x < grp_xlim(iG, 2);
            if any(isnan(stPSTH.(fn{iF}).mean(bValid(iG, :))))
               warning('psth %s group %d has NaN in the range %.1f - %.1f',  ...
                   fn{iF}, iG, grp_xlim(iG, 1), grp_xlim(iG, 2) );
            end
        end
    end
end

% resample trials from individual PSTHs
bVSession = false(nF, 1);
for iF = 1:nF
%     if ~isfield(stPSTH.(fn{iF}), 'rate_rsp')
%         bVSession(iF) = false;
%         fprintf(1, 'cannot find rate_rsp in %s\n', fn{iF});
%         continue;
%     end
%     if isempty(stPSTH.(fn{iF}).rate_rsp)
%         bVSession(iF) = false;
%         fprintf(1, 'rate_rsp in %s is empty\n', fn{iF});
%         continue;
%     end
    % sample trials from rate_rsp
    [all_x{iF} all_rsp{iF} all_grp{iF}] = sample_trials_psth(stPSTH.(fn{iF}), n_grps, minmax(x), shuffled_pick);
    if all(isnan(all_grp{iF}))
        disp([fn{iF} ' rate_rsp is empty']);
        bVSession(iF) = false;
        cMissing = {cMissing{:}, fn{iF}};
    else
        bVSession(iF) = true;
    end
end

if debug
    figure;
    for iF = 1:nF
        imagesc(all_x{iF}, [], all_rsp{iF})
        draw_refs(0, 0, NaN);
        title(['Resampled from ' fn{iF}])
        pause(0.1);
    end
end

% combine resampled trials responses
ar_rsp = cat(3, all_rsp{:});
sum_rsp = nansum(ar_rsp, 3);
% nansum just make zero for all-NaNs
sum_rsp(all(isnan(ar_rsp), 3)) = NaN;


% plot combined PSTHs
% z-score responses
switch(estimator)
    case {'zscore'}
        all_psth.rate_rsp = (sum_rsp - nanmean(sum_rsp(:))) / nanstd(sum_rsp(:));
    case 'sum'
        all_psth.rate_rsp = sum_rsp;
    otherwise
        error('Unknown estimator: %s', estimator);
end

all_psth.x = x;
all_psth.grp = all_grp{end};

% get table for averaged events
event_tb = get_mpsths_events(stPSTH);

[ax h_psth pop_psth] = plot_timecourse('stream', 1:100, 10*ones(size(all_psth.grp)), 0, 10, all_psth.grp, ...
    'use_this_psth', all_psth, 'test_diff', test_diff, 'parent_panel', ax, 'grp_xlim', grp_xlim, ...
    'adjust_clim', 0.5, 'mean_crit', 0.98, 'base_sub_win', base_sub_win, 'split_v', split_v);

atitle(ax(1), sprintf('Resample from %d/%d psths', nnz(bVSession), numel(bVSession) ));
ylabel(ax(2), estimator);

% plot event on psth
plot_event_on_psth_table(event_tb, 'ax', ax(2), 'events_header', event_header);

% assign event table
pop_psth.event = event_tb;

% assign ginfo
if isfield(stPSTH.(fn{find(bVSession,1, 'first')}), 'ginfo') 
    pop_psth.ginfo = stPSTH.(fn{find(bVSession,1, 'first')}).ginfo;
end