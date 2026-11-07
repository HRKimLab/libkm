function [sm_base fp_base] = get_photometry_baseline_simple(raw, winlen, pctCrit, debug)
% simple version of get_photometry_baseline. This does not distinguish
% TI and ITI (inter-trial interval) to compute baseline.

raw_ITI = raw;

fp_base = NaN(size(raw_ITI));      % low 1% signal
sm_base = NaN(size(raw_ITI));      % spline fit of the above
subsample_int = 100;                 % subsample every 100ms

for ii=1:250:length(raw_ITI)-(winlen/2)
      % get samples time for this time window
      start_idx = ii-(winlen/2); end_idx = ii+(winlen/2);
      if start_idx < 1, start_idx = 1; end;
      sample_time = start_idx:subsample_int:end_idx;
    
      % prctile function ignore NaN, and I may not need to check too small
      % sample size in this increased winlen
      fp_base(ii) = prctile(raw_ITI( sample_time ), pctCrit);
end

% first win_len has the biggest drop. use increasing windows from the left
fp_base(1:min([winlen length(raw_ITI)])) = NaN;
for ii = 1000:1000:min([winlen length(raw_ITI)])
    start_idx = max([1 ii-6000]); end_idx = ii+2000+ii/5;
    fp_base(ii) = prctile(raw(start_idx:10:min([end_idx length(raw)]) ), pctCrit);
end

% % spine fit is sometimes weird when the end is not constrained. 
% % Just use the first and last non-TI value when doing spline
% iFirstBase = find( ~isnan(fp_base) ,1,'first');
% fp_base(1:iFirstBase) =  fp_base( iFirstBase );
% fp_base(data.tr.TrialOff(iValidTrials(end))+1:end) = fp_base( find( ~isnan(fp_base) ,1,'last') );
bV = ~isnan(fp_base);
% sm_base = spline(data.motor_time(bV(1:length(data.motor_time))), fp_base(bV(1:length(data.motor_time))), data.motor_time);
% changed from spline to linear interpolation 9/6/2017 HRK
t_time = 1:numel(fp_base);
sm_base = interp1(t_time(bV), fp_base(bV), t_time, 'linear');
