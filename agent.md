# libkm Codebase Understanding

## What this repository is

`libkm` is a reusable MATLAB toolbox for behavioral and neural data analysis. It is not a single application. It is a collection of cooperating libraries that support common lab workflows for:

- storing per-session analysis outputs
- loading those outputs into population tables
- plotting and statistically testing population summaries
- computing and combining PSTHs
- performing state-space analysis on timecourse data

## Top-level structure

- `demo/`
  End-to-end examples showing how the toolbox is intended to be used.

- `libbigtable/`
  Aggregates many per-session result files into one large array or table keyed by unit/session identifiers.

- `libpopulation/`
  Population plotting and statistical analysis functions working mostly on column vectors or grouped arrays.

- `libtimeseries/`
  PSTH and event-aligned time-course analysis toolkit.

- `libss/`
  State-space analysis on PSTH-derived arrays such as TCN and TNC.

- `libutil/`
  Shared utility layer used everywhere else.

## Main mental model

The toolbox is built around this workflow:

1. Run per-session analyses and save one-line results or PSTH structs.
2. Load many sessions together.
3. Build a population table or PSTH collection.
4. Filter after loading rather than partially loading.
5. Plot and test many hypotheses quickly.
6. Move into state-space or multidimensional summaries when needed.

In short:

`session results -> aggregation -> filtering -> population plots / PSTHs -> advanced analysis`

## Module understanding

### libbigtable

This module is the aggregation backbone.

Main ideas:

- combines distributed result files into `aPD` or `tPD`
- uses `unitname` as the primary key
- assumes the first five columns represent the unit key values
- resolves duplicate entries by using the last result found
- treats missing values as `NaN`

Representative files:

- `StoreResults.m`
- `LoadPopulationData5Key.m`
- `load_population_data_table.m`
- `pd2tb.m`

### libpopulation

This is the exploratory statistics and plotting layer.

Main ideas:

- plot data fast during exploratory analysis
- attach relevant statistical tests by default
- work naturally with columns extracted from `aPD`

Representative files:

- `plot_scatter.m`
- `plotsqscatter.m`
- `plot_histgrp.m`
- `plot_histsig.m`
- `plot_bargrp.m`
- `plot_barpair.m`
- `plot_xygrp.m`
- `test_same_dist.m`

### libtimeseries

This is the largest and most feature-rich module.

Main ideas:

- compute PSTHs aligned to events
- save PSTHs to `.mat`
- load many PSTHs across subjects/sessions
- filter by group or condition
- combine PSTHs with different time ranges
- plot individual and population timecourses

Representative files:

- `plot_timecourse.m`
- `compute_psth.m`
- `asave_psth.m`
- `load_psth_files.m`
- `filter_psth.m`
- `filter_psth_group.m`
- `homogenize_psths.m`
- `plot_mpsths.m`
- `plot_mpsth_xneuron.m`
- `plot_mpsth_xsubject.m`

Important data contract:

- the `psth` struct with fields like `x`, `mean`, `sem`, `event`, `rate_rsp`, and `ginfo`

### libss

This module sits on top of time-series outputs and performs state-space analysis.

Representative files:

- `psth2ss.m`
- `TCN2ss.m`
- `TNC2ss.m`
- `analyze_state_space.m`
- `analyze_state_space_TNC.m`
- `plot3_TCN.m`

The typical use is:

- load PSTHs
- convert to TCN/TNC/state-space format
- run PCA or related trajectory analyses
- visualize trajectories or cluster structure

### libutil

This is the support layer used by almost every other module.

Notable categories:

- plotting helpers: `setfig`, `gna`, `create_figure`, `draw_refs`, `setlim`
- key-value parsing: `process_varargin`
- NaN-aware stats helpers: `nansem`, `nnum`, `nonnans`
- grouping/table helpers: `filter_table`, `group_table`
- naming/path helpers: `add_repo`, `str2unitkey`, `unitkey2str`

## Demo understanding

`demo/demo_population_analysis_framework.m` is the best first file to read.

It shows the intended philosophy clearly:

- add the toolbox folders to MATLAB path
- declare result files and headers
- load `aPD` using `LoadPopulationData5Key`
- create boolean masks for subsets of interest
- load PSTHs with `load_psth_files`
- filter PSTHs after loading
- perform population bar/scatter/pair plots
- perform population PSTH analysis

That file makes it clear that the toolbox is designed for broad loading followed by interactive slicing.

## Design characteristics

This repo has a strong practical-lab-toolbox feel:

- path-based MATLAB usage rather than package-based APIs
- emphasis on reusable workflows over object-oriented design
- lots of helper functions to reduce analysis boilerplate
- convention-driven file formats and naming
- demos used as the main teaching/documentation layer

## Strengths

- coherent workflow from single-session outputs to population summaries
- strong support for PSTH and event-aligned analyses
- convenient plotting functions with attached statistics
- demos make onboarding easier
- broad utility layer reduces repeated analysis code

## Risks and limitations

- correct use depends on following naming and file-format conventions
- some dependencies are external and optional rather than bundled
- discoverability can be hard because there are many utility functions
- reproducibility depends on path setup and stable local conventions
- some parts still rely on classic MATLAB workspace/script patterns

## Best files to read first

1. `README.md`
2. `Contents.m`
3. `demo/demo_population_analysis_framework.m`
4. `libbigtable/README.md`
5. `libtimeseries/README.md`
6. `libpopulation/demo_population_analysis_functions.m`
7. `libtimeseries/demo_timecourse_data_analysis.m`
8. `libss/demo_analyse_state_space.m`

## My main conclusion

`libkm` is best viewed as a shared neuroscience/behavior analysis toolbox with five core layers:

- `libbigtable` for aggregation
- `libpopulation` for exploratory population stats and plots
- `libtimeseries` for PSTHs and event-aligned data
- `libss` for state-space analysis
- `libutil` for everything that supports those layers

It is optimized for helping lab members move quickly from per-session analyses to population-level scientific figures.
