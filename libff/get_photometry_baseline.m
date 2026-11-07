function [sm_base fp_base] = get_photometry_baseline(raw, winlen, pctCrit, debug)
% get baseline of photometry signal
% sm_base: baseline fp_base: un-interpolated baseline (for debug)
% 2016 HRK
global gC; struct2var(gC); % VirMEn_Def
global data

assert(mod(winlen,2) == 0)

if ~is_arg('pctCrit')
    pctCrit = 10;
end
if ~is_arg('debug')
    debug = 0;
end


% ignore response during trial duration and [0 5s] after unexpected reward
raw_ITI = raw;
iValidTrials = find(~isnan(data.tr.TrialOn))';

switch(data.one_time_params.Protocol)
    case VR_FREEMOVE_WO_REW % no difference between ITI and ISI in VR_FREEMOVE_WO_REW    
    otherwise % use responses during ITI for baseline and ignore responses during TI
    for iT = iValidTrials
        raw_ITI(data.tr.TrialOn(iT):min([data.tr.TrialOff(iT)+2000 end])) = NaN;
    end
    for iT = find(~isnan(data.tr.UnexpRewOn))'
        raw_ITI(data.tr.UnexpRewOn(iT):min([data.tr.UnexpRewOn(iT)+5000 end])) = NaN;
    end
end

% ignore response after trial end. after, I pull out connector and measure F0.
raw_ITI(data.tr.TrialOff(iValidTrials(end)):end) = NaN;

fp_base = NaN(size(raw_ITI));      % low 1% signal
sm_base = NaN(size(raw_ITI));      % spline fit of the above
subsample_int = 100;                 % subsample every 100ms
% take pctCrit% from lowest instead min. 10/5/2016 HRK
% for ii=(winlen/2+1):200:length(raw_ITI)-(winlen/2)
for ii=1:250:length(raw_ITI)-(winlen/2)
      % get samples time for this time window
      start_idx = ii-(winlen/2); end_idx = ii+(winlen/2);
      if start_idx < 1, start_idx = 1; end;
      sample_time = start_idx:subsample_int:end_idx;
    
      % prctile function ignore NaN, and I may not need to check too small
      % sample size in this increased winlen
      fp_base(ii) = prctile(raw_ITI( sample_time ), pctCrit);
%       sample_vals = nonnans(raw_ITI( sample_time ));
%       nValid = numel(sample_vals);
%       if nValid > 500/subsample_int
%           fp_base(ii) = prctile(sample_vals, pctCrit);
%       else
%            fp_base(ii) = NaN;
%       end
end

% first win_len has the biggest drop. use increasing windows from the left
fp_base(1:min([winlen length(raw_ITI)])) = NaN;
for ii = 1000:1000:min([winlen length(raw_ITI)])
    start_idx = max([1 ii-6000]); end_idx = ii+2000+ii/5;
    fp_base(ii) = prctile(raw(start_idx:10:min([end_idx length(raw)]) ), pctCrit);
end

% spine fit is sometimes weird when the end is not constrained. 
% Just use the first and last non-TI value when doing spline
iFirstBase = find( ~isnan(fp_base) ,1,'first');
fp_base(1:iFirstBase) =  fp_base( iFirstBase );
fp_base(data.tr.TrialOff(iValidTrials(end))+1:end) = fp_base( find( ~isnan(fp_base) ,1,'last') );
bV = ~isnan(fp_base);
% sm_base = spline(data.motor_time(bV(1:length(data.motor_time))), fp_base(bV(1:length(data.motor_time))), data.motor_time);
% changed from spline to linear interpolation 9/6/2017 HRK
sm_base = interp1(data.motor_time(bV(1:length(data.motor_time))), fp_base(bV(1:length(data.motor_time))), data.motor_time, 'linear');

if debug
    setfig(3,1);
    gna;
    plot((1:length(fp_base))/1000, [raw'],'k-');
    hold on;
    % mark raw signal that is used for drift correction
    plot((1:length(fp_base))/1000, raw_ITI', 'bx','markersize', 3);
    % mark interpolated baseline
    plot((1:length(fp_base))/1000, sm_base', 'r-');
    % mark un-interpolated baseline
    plot((1:length(fp_base))/1000, fp_base', 'r.');
    
    
    draw_refs(0, data.tr.UnexpRewOn/1000);
    
    iITI = find(~isnan(raw_ITI));
    plot(iITI/1000, ones(size(iITI)) * max(raw),'g.');
    hold off;

    % just takes time without much info
%     gna;
%     plot_histgrp(raw, isnan(raw_ITI));
%     legend('ITI','TI');
end

return