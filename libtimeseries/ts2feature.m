function f = ts2feature( ts_resp, trigger, trial_start, trial_end, mode, varargin)

% compute instantaneous rates
[x, rate_rsp array_rsp base_rate] = compute_rate('timestamp', ts_resp, trigger, trial_start, trial_end);

nT = size(trigger, 1);
f = NaN(nT, 1);

switch(mode)
    case 'latency' 
        assert(any(x >= 0), 'start_trial should include 0');
        for iT = 1:nT
            [iC] = find(array_rsp(iT, x > 0), 1, 'first');
            if isempty(iC)
                f(iT, 1) = NaN;
            else
                f(iT, 1) = iC;
            end
        end
    case 'latency_nb' % latency, no boundary
        for iT = 1:nT
            ts_ab_start = ts_resp - trial_start(iT);
            iFirst = find(ts_ab_start > 0, 1, 'first');
            if isempty(iFirst)
                f(iT, 1) = NaN;
            else
                f(iT, 1) = ts_ab_start(iFirst);
            end
        end
end