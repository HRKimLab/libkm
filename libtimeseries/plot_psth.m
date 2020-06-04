function plot_psth(ts_resp, trigger, trial_start, trial_end, hist_bin)
% plot peri-stimulus time histogram
% see plot_psma for plotting moving average
% 11/17/2017 HRK
ax_psth = gca;

[nHist hist_edges] = compute_psth(ts_resp, trigger, trial_start, trial_end, hist_bin);

bar(ax_psth, hist_edges, nHist, 'histc');
xlim(ax_psth, minmax(hist_edges));
draw_refs(0, 0, NaN);
% In this case, change x and rate_rsp accordingly.
x = hist_edges;
rate_rsp = nHist';