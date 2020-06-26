# libtimeseries
libtimeseries provides an integrative way to plot and manage behavioral and neural time course data. It is specialized in handling seconds-scale data in trial structure with multiple conditions. You can do the following things: Plot raster and moving average (PSTH); save PSTH; load data and plot population time course; analyze multi-dimensional dynamics

## Basic
plot_timecourse('timestamp', msSpikes, msReward, -3000, 3000, grp);

## Advanced options

| Option   | value        | description         |
|----------|--------------|---------------------|
|-win_len  | integer (ms) | window length in ms |

## Save PSTH
[ax, h_psth, psth] = plot_timecourse(...) <br>
m2034s23r1 = psth; % assign psth to a variale with the dataname <br>
asave('D:\foo\bar.mat', 'm2034s23r1');

## load PSTH

## Plot population data
```
psths = load('D:\foo\bar.mat');
plot_mpsths(psths);
```
