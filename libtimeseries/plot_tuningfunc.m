function [hP] = plot_tuningfunc(data_type, ts_resp, trigger, trial_start, trial_end, grp, varargin)

bTrialData = [];
plot_type = 'bar';
func = @nanmean;

process_varargin(varargin);

rates = conv2rate(data_type, ts_resp, trigger + trial_start, trigger + trial_end);

switch(plot_type)
    case 'line'
        hP = plot_xyerr(grp, rates);
    case 'bar'
        plot_bargrp(rates, grp);
end