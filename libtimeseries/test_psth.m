function [v p] = test_psth(psth, time_window, method, grp, ax)
% psth: psth structure
% time_window: time window
v = NaN; p = NaN;
if isempty(psth)
    return;
end

if is_arg('grp')
    bV = psth.grp == grp;
else
    bV = true(size(psth.grp));
end

if ~is_arg('ax'), ax = [];
else
    if length(ax) == 2
        % use psth axis
        ax = ax(2);
    end
    % make sure that it is psth axis
    assert(strcmp(get(ax, 'tag'), 'psth'));
end

% identify baseline and response window
bBase = (psth.x >= time_window(1)) & (psth.x < time_window(2));
bResp = psth.x >= time_window(3) & psth.x < time_window(4);

% methods that do not need individual trials (rate_rsp)
switch(method)
    case 'peak_time'
        idx_win_start = find(psth.x >= time_window(3), 1, 'first');
        v = NaN(size(psth.mean,1), 1); p = NaN(size(v));
        for iG = 1:size(psth.mean,1)
            [v(iG) p(iG)] = max(psth.mean(iG, bResp), [], 2);
            p(iG) = psth.x(idx_win_start + p(iG));
        end
        
        if ~isempty(ax)
            prv = get(ax, 'nextplot');
            set(ax, 'nextplot','add');
            hP = line(p, v, 'linestyle','none','marker', 'v','markersize',5,'parent', ax);
            set(hP, 'tag','peak');
            set(ax,'nextplot', prv);
        end
        
        return;
end

% method that needs individual trials (rate_rsp)
rB = nanmean(psth.rate_rsp(bV, bBase), 2);
rR = nanmean(psth.rate_rsp(bV, bResp), 2);
        
switch(method)
    case 'roc'
        [v p] = ROC_signif_test(rR, rB);
    case 'dprime'
        assert(size(psth.mean,1) == 1);
        sig1 = mean( psth.std( bBase ) );
        sig2 = mean( psth.std( bResp ) );
        m1 = mean( psth.mean( bBase ) );
        m2 = mean( psth.mean( bResp ) );
        v = (m2 - m1) / sqrt( (sig1^2 + sig2^2)/2 );
    otherwise
        error('Unknown method: %s', method);
end