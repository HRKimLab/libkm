# libtimeseries
libtimeseries provides an integrative way to plot and manage behavioral and neural time course data. It is specialized in handling trial structure with multiple conditions and differen events.

see demo_timecourse_data_analysis.m for a demo with detailed comments.

# What you can do

- plot a PSTH (show raster + average across trials for each condition)
- save a PSTH
- load multiple PSTHs
- filter PSTHs
- combine PSTHs with different time range (e.g., homogenize x axis of PSTHs)
- plot individual or population PSTHs
- perform multi-dimensional population analyses

# Examples
### Sinle-session time courses
<img src=demo_Fig1.png alt="Fig1" width="400"> <img src=demo_Fig2.png alt="Fig2" width="400"> 
### Population time courses: inspect individuals and plot the average
<img src=demo_lick_xsession.png alt="xsession" width="400"> <img src=demo_lick_mpsths.png alt="mpsths" width="400"> 

# Details
### psth struct
The table below describes select fields of psth struct, which is the main output of plot_timecourse.

| name |  size | description |
|------|-------|-------------|
| x    |[1 * # of timepoints]             | time point of PSTHs |
| mean | [# of groups * # of timepoints]  | average activity for each group |
| sem  | [# of groups * # of timepoints]  | standard error of mean for each group |
| std  | [# of groups * # of timepoints]  | standard deviation for each group |
| numel  | [# of groups * # of timepoints]  | # of valid trials for each group |
| pDiff  | [1 * # of timepoints]  | p-values to test whether responses are same or different across groups  |
| pBaseDiff  | [# of groups * # of timepoints]  | p-values to test whether responses are same or different from baseline  |
| event  | [1 * # of events]  | a table containing the medians of events |
| rate_rsp  | [# of trials * # of timepoints]  | trial-to-trial responses that was used to compute the averages for each group|
| ginfo.grp_idx |   [# of trials * 1] |   group index |
| ginfo.unq_grp_label |  [# of groups * 1] |  string label for the group index |

