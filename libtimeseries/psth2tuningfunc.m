function [hP mean_rate trial_rate] = psth2tuningfunc(psth, sTrigger, sWin, varargin)
% get tuning function from psth structure
% see also plot_tuningfunc for more accurate rate computation for timestamp
% 2019 HRK

grp = [];
bTrialData = [];
plot_type = 'bar';
remap = [];

func = @nanmean;

process_varargin(varargin);

if ~is_arg('grp'), grp = psth.grp; end
if ~is_arg('bTrialData'), bTrialData = true(size(psth.rate_rsp, 1), 1); end

bTOI = psth.x >= sWin(1) & psth.x < sWin(2);

% using rate_rsp make ti not 'perfectly accurate' for spikes 
% since rate spike_rate is a smoothed version of firing rates. 
% It will look at average of 'smoothed out' instantaneous responses
rates = func(psth.rate_rsp(:, bTOI), 2);

if ~isempty(remap)
   grp = remap_array(grp, remap(1,:), remap(2,:) ); 
end

switch(plot_type)
    case 'line'
        hP = plot_xyerr(grp, rates);
    case 'bar'
        plot_bargrp(rates, grp);
end