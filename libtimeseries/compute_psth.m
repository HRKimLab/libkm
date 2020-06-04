function [nHist hist_edges] = compute_psth(ts_resp, trigger, trial_start, trial_end, hist_bin)
% compute histogram from timestamp
% 10/31/2017 HRK
hist_edges = trial_start:hist_bin:trial_end;
hist_edges = hist_edges/1000;
nHist = [];
if nnum(ts_resp) > 0 && nnum(trigger) > 0
    [x array_rsp] = ts2array(ts_resp, trigger, trial_start, trial_end);
    x = x / 1000;
    array_x = repmat(x, [size(array_rsp,1) 1]);
    
    [nHist] = histc(array_x(logical(array_rsp)), hist_edges);
    nHist = nHist(:); % shape not consistent when numel(triger) == 1
end
if isempty(nHist)
    nHist = zeros(length(hist_edges), 1); % to avoid assignment error below
end