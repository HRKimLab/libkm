function [xl yl] = get_plot_range(psth, adj_xl)

if ~is_arg('adj_xl'), adj_xl = 1; end

% find a range of x that contains 95% of trials
xl = [0 1]; yl = [0 1];

if all(isnan(psth.x)) % possible if x(t) is NaN for some reason (e.g., before setup is established..)
    return; 
end
sug_xl = [psth.x(find( sum(psth.numel, 1) > size(psth.rate_rsp, 1) * 0.05, 1, 'first')) ...
    psth.x(find( sum(psth.numel, 1) > size(psth.rate_rsp,1) * 0.05, 1, 'last'))];
if adj_xl && numel(sug_xl) == 2 && sug_xl(1) < sug_xl(2)
    xl = sug_xl;
else
    xl = [psth.x(1) psth.x(end)];
end

bVX = psth.x >= xl(1) & psth.x <= xl(2);

% set ylim range
% yl = get(gca, 'ylim');
mMax = nanmax(nanmax(psth.mean(:, bVX)));
mMin = nanmin(nanmin(psth.mean(:, bVX)));

is_valid = false(size(psth.mean));
for iG = 1:size(psth.mean,1)
    % only plot non-NaN datapoints
    is_valid(iG,:) = ~isnan(psth.mean(iG,:)) & ~isnan(psth.sem(iG,:)); % & numel(iG,:) > 10;
    nMaxT = nanmax(psth.numel(iG,:)) ;
    if nMaxT > 10
        is_valid(iG,:) = is_valid(iG,:) & (psth.numel(iG,:) > nMaxT * 0.1);
    end
end

if all(is_valid == false)
    return;
end

mMax = nanmax(nanmax(psth.mean(is_valid)));
mMin = nanmin(nanmin(psth.mean(is_valid)));
% range based on group means
mP2P = [mMin - (mMax - mMin)*0.1 mMax + (mMax - mMin)*0.1];
% range based on mean +- s.e.m.
mMaxSEM = nanmax(nanmax(psth.mean(:, bVX) + psth.sem(:, bVX) * 1.1));
mMinSEM = nanmin(nanmin(psth.mean(:, bVX) - psth.sem(:, bVX) * 1.1));

if ~isempty(psth.mean(:, bVX))
%     if mMax > 0
%         yl(2) =  min([mMax * 1.2 mMaxSEM]);
%     elseif mMax < 0
%         yl(2) =  min([mMax * 0.9 mMaxSEM]);
%     end
%     yl(2) = min([mP2P(2) mMaxSEM]);
%     yl(1) = max([mP2P(1) mMinSEM]);
    yl(2) = max([mP2P(2) mMaxSEM]);
    yl(1) = min([mP2P(1) mMinSEM]);
%     if mMin >= 0
%         yl(1) = max([mMin * 0.9 mMinSEM]);
%         set(gca, 'ylim', [-1 yl(2)]);
%     else % likely to be fiber photometry 
%         yl(1) =  max([mMin * 1.1 mMinSEM]); 
%     end
    if all(~isnan(yl)) && yl(1) ~= yl(2)
    else
        yl = [0 1];
    end
    
end