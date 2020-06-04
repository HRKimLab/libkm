# libtimeseries
Plot moving average; plot average of them across population

## Examples
You have spike timestamp (n_signal), event that you want to align (trig), start time (st), end time (et), groups (grp)
plot_timecourse('timestamp', n_signal, trig, st, et, grp);

## plot_timecourse: Basic arguments
plot_timecourse(data_type, n_signal, trig, st, et, grp);
- data_type: 'timestamp', 'stream'
- n_signal: 'timestamp': 1 X n timestamps of events in ms
          'stream' : stream of data (1 X m)
- trig: event to trigger n_signal in ms (nEvent X 1).
- st: start time to plot signals. single value for the timing relative to trigger (ms), array (nEvent X 1) for absolute timing.
- et: end time to plot signals. single value for the timing relative to trigger (ms), array (nEvent X 1) for absolute timing.
-  grp: group information for each trigger (nEvent X 1).

## plot_timecourse: Advanced arguments

| Option   | value        | description         |
|----------|--------------|---------------------|
|-win_len  | integer (ms) | window length in ms |


## Save
[ax, h_psth, psth] = plot_timecourse(...) <br>
m2034s23r1 = psth; % assign psth to a variale with the dataname <br>
asave('D:\foo\bar.mat', 'm2034s23r1');     % asave is in [libutil][]

[libutil]: https://github.com/hkim09/libutil/

## Plot population data
psths = load('D:\foo\bar.mat'); <br>
plot_mpsths(psths);

