function [x array_rsp n_resp] = ts2array(ts_resp, trigger, trial_start, trial_end)
% ts2array convert timestamp to trial-based array. all units are milisecond
% redundant values in ts_resp are ignored.
% HRK 7/2/2015

n_trial = size(trigger, 1);

if isempty(trigger) || isempty(trial_start) || isempty(trial_end)
    x = []; array_rsp = []; n_resp = []; 
    return
end

% if trial_start and trial_end are single, it's time relative to trigger
if numel(trial_start) == 1, trial_start = trigger + trial_start; end
if numel(trial_end) == 1, trial_end = trigger + trial_end; end

assert(all(size(trial_start) == size(trial_end)) && all(size(trigger) == size(trial_end)), ...
    'The size of trigger, trial_start, and trial_end should be same');

% round miliseconds
ts_resp = round(ts_resp); trigger = round(trigger); 
trial_start = round(trial_start); trial_end = round(trial_end);

% find lower boundary, high boundary, and max len
x_lb = min(trial_start - trigger);
x_hb = max(trial_end - trigger);
max_len = x_hb - x_lb + 1; % time 0 is column 1

% avoid mistakenly assign too large memory
if max_len > 45 * 1000, log4m.getLogger().warn('ts2array', 'max len(%f) exceed 45sec. is this correct?', max_len); end;
% assert(max_len < 240 * 1000, sprintf('length (%.2f) exceeds 60 second.', max_len)); % this is nonsense.
% I also want to plot whole session data. check actual memory usage instead single trial len.
assert(n_trial * max_len * 8 / 1024 / 1024 < 700, '# of trigger(%d) * max len(%d) is too big', n_trial, max_len);
% generate time axis
x = x_lb:x_hb;

% allocate memory for the array
array_rsp = NaN(n_trial, max_len);
n_resp = NaN(n_trial, 1);

% iterate trials and put response into the array
for iT = 1:n_trial
   % skip if any of the timing events is NaN
   if isnan(trigger(iT)) || isnan(trial_start(iT)) || isnan(trial_end(iT)) 
       n_resp(iT) = NaN; continue; 
   end
   % assign zero to the valid trial period
   array_rsp( iT, x >= trial_start(iT) - trigger(iT) & x <= trial_end(iT) - trigger(iT) ) = 0;
   % find events within the current trial
   ts_aligned = ts_resp(ts_resp >= trial_start(iT) & ts_resp <= trial_end(iT)) - trigger(iT);
   % assign the number of event
   array_rsp(iT, ts_aligned - x_lb + 1) = 1;
   % put # of response
   n_resp(iT) = length(ts_aligned);
end

% make sure that the array size is not automatically expanded by
% out-of-range index
assert(size(array_rsp,2) == max_len);