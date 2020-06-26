# libtimeseries
libtimeseries provides an integrative way to plot and manage behavioral and neural time course data. It is specialized in handling seconds-scale data in trial structure with multiple conditions. You can do the following things: Plot raster and moving average (PSTH); save PSTH; load data and plot population time course; analyze multi-dimensional dynamics

## Examples
plot spike timestamp (spike_ts) aligned by events (trig), using a time window defined by start time (st) and end time (et). If needed, sort trials by trial conditions (grp).
plot_timecourse('timestamp', spike_ts, trig, st, et, grp);

## plot_timecourse: Basic
plot_timecourse(data_type, n_signal, trig, st, et, grp);
- data_type: 'timestamp', 'stream'
- n_signal: 'timestamp': 1 X n timestamps of events in ms
          'stream' : stream of data (1 X m)
- trig: event to trigger n_signal in ms (nEvent X 1).
- st: start time to plot signals. single value for the timing relative to trigger (ms), array (nEvent X 1) for absolute timing.
- et: end time to plot signals. single value for the timing relative to trigger (ms), array (nEvent X 1) for absolute timing.
-  grp: group information for each trigger (nEvent X 1).

## plot_timecourse: Advanced

| Option   | value        | description         |
|----------|--------------|---------------------|
|-win_len  | integer (ms) | window length in ms |


## Save
[ax, h_psth, psth] = plot_timecourse(...) <br>
m2034s23r1 = psth; % assign psth to a variale with the dataname <br>
asave('D:\foo\bar.mat', 'm2034s23r1');

## Plot population data
```
psths = load('D:\foo\bar.mat');
plot_mpsths(psths);
```
