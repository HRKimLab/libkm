function [mean_rate trial_rate] = psth2rate(psth, sTrigger, sWin, func, bTrialData)
% PSTH2RATE Calculate mean response from psth in the given time window
% returns [# of groups, 1]
% 2018 HRK
assert(isstruct(psth), 'psth should be structure with psths');
if ~is_arg('func'), func = @(x) nanmean(x, 2); end;
if ~is_arg('sWin'), sWin = minmax(psth.x);     end;
if ~is_arg('bTrialData'), bTrialData = 0;      end;

nG = size(psth.mean, 1);
mean_rate = NaN(nG, 1);
trial_rate = [];

% get window relative to trigger or event
[sTrigger sWin] = psth2time(psth, sTrigger, sWin);

bV = false(size(psth.mean));
for iG = 1:nG
    if all(isnan(sWin(iG,:))), bV(iG,:) = false; continue; end
    % get valid range based on time window
    bV(iG,:) = sWin(iG, 1) <= psth.x & psth.x < sWin(iG, 2);
    % take the range where # of lements are more than 1/3
    % otherwise the noisy mean from a few trials will dominate computation.
    bVN = psth.numel(iG,:) > (psth.n_grp(iG) / 3);
    if any(bVN & bV(iG,:) ~= bV(iG,:))
        warning('Valid window was trimmed to avoid noisy mean from less # of valid trials');
    end
    bV(iG,:) = bV(iG,:) & bVN;
end

% func
if isa(func, 'function_handle')
    str_func = func2str(func);
elseif isstr(func)
    str_func = func;
end

switch(str_func)
    case {'peaktime'}
        tmp = psth.mean;
        tmp(~bV) = NaN;
        [vM, iM] = nanmax(tmp, [], 2);
        mean_rate = psth.x(iM)';
        % as opposed to vM, iM doesn't give NaN even if all row is NaN.
        mean_rate(isnan(vM)) = NaN;
        
        % compute trial-by-trial rate_rsp
        if isfield(psth, 'rate_rsp') && bTrialData
            
        end
    case {'peak'}
        tmp = psth.mean;
        tmp(~bV) = NaN;
        [vM, iM] = nanmax(tmp, [], 2);
        mean_rate = vM';
        % as opposed to vM, iM doesn't give NaN even if all row is NaN.
%         mean_rate(isnan(vM)) = NaN;
        
        % compute trial-by-trial rate_rsp
        if isfield(psth, 'rate_rsp') && bTrialData
            rate_rsp = psth.rate_rsp;
            trial_rate = NaN(size(psth.rate_rsp,1), 1);
            
            for iT = 1:size(psth.rate_rsp,1)
                if isnan(psth.ginfo.grp_idx(iT))
                    continue;
                end
                % valid time points
                bVTime = bV(psth.ginfo.grp_idx(iT),:);
                % nullify invalid rates
                rate_rsp(iT, ~bVTime) = NaN;
                % get max
                trial_rate(iT,1) = nanmax(rate_rsp(iT, :), [], 2); 
            end
        end
    case {'dy'}  % 'y', invalid 'y' since it gives two column output.
        
        for iG = 1:nG
            % skip if sWin is NaN
            if any(isnan(sWin(iG,:))), continue; end
            
            tmp = bsxfun(@minus,minmax(psth.x), sWin(iG, [1 2])' );
            % x range - timing should be
            if ~all(tmp(:,1) <= 0 & tmp(:,2) >= 0)
                error('psth2rate y: time window is out of psth.x');
            end
            
            iStart = find_closest(sWin(iG, 1), psth.x)
            iEnd = find_closest(sWin(iG, 2), psth.x)
            
            mean_rate(iG, 1) = psth.mean(iG, iStart);
            mean_rate(iG, 2) = psth.mean(iG, iEnd);
        end
        
        if strcmp(str_func, 'dy')
           mean_rate =  mean_rate(:,2) - mean_rate(:,1);
        end
        
    case {'sum'}
        for iG = 1:nG
            % skip if sWin is NaN
            if any(isnan(sWin(iG,:))), continue; end
            
            % find indice for start and end
            tmp = bsxfun(@minus,minmax(psth.x), sWin(iG, [1 2])' );
            % x range - timing should be
            if ~all(tmp(:,1) <= 0 & tmp(:,2) >= 0)
                error('psth2rate y: time window is out of psth.x');
            end
            iStart = find_closest(sWin(iG, 1), psth.x)
            iEnd = find_closest(sWin(iG, 2), psth.x)
            
            mean_rate(iG, 1) = sum(psth.mean(iG, iStart:iEnd));
        end
        
    otherwise
        for iG = 1:nG
            if ~any(bV(iG,:))
                mean_rate(iG, 1) = NaN; 
                continue; 
            end
            
            mean_rate(iG, 1) = func( psth.mean(iG, bV(iG,:)) );
        end
        
        % compute trial-by-trial rate_rsp
        if isfield(psth, 'rate_rsp') && bTrialData
            rate_rsp = psth.rate_rsp;
            trial_rate = NaN(size(psth.rate_rsp,1), 1);
            
            for iT = 1:size(psth.rate_rsp,1)
                if isnan(psth.ginfo.grp_idx(iT))
                    continue;
                end
                % valid time points
                bVTime = bV(psth.ginfo.grp_idx(iT),:);
                % nullify invalid rates
                rate_rsp(iT, ~bVTime) = NaN;
                % get max
                trial_rate(iT,1) = func(rate_rsp(iT, :)); 
            end
        end
end