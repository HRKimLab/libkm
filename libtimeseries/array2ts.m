function [event, trigger] = array2ts(ar, ab)
% convert trial-based array to vectors that is used in plot_timecourse
% ar is m X n array. m trial #, n is the # of time bin in ms.
% ab is a time point in n bins that you want to align events with.
% 12/7/2017 HRK
warning('array2ts: Not tested yet. Use at your own risk!');
event = []; trigger = [];
offset = size(ar, 2) + 1000;
if ~is_arg('ab'), ab = 1; end;

for iT = 1:size(ar, 1);
    % detect onset and concatenate
    onset = find(ar(iT, :))';
    event = [event; onset + offset * (iT-1)];
    trigger = [trigger; offset * (iT-1) + ab];
end