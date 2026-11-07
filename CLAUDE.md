# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**libkm** is a MATLAB toolbox for behavioral and neural data analysis (single-unit, population, and time-series). It is the main analysis toolbox in NeuRLab (HyungGoo Kim). There is no build system — functions are used directly by adding folders to the MATLAB path.

## Setup

Add all subfolders to the MATLAB path:
```matlab
addpath(genpath('path/to/libkm'))
```

**Dependencies:**
- `process_varargin.m` from [MClust](http://redishlab.neuroscience.umn.edu/mclust/MClust.html) — used by many functions
- [panel](https://www.mathworks.com/matlabcentral/fileexchange/20003-panel) — optional, for packed plots in `plot_timecourse`
- [sigstar](https://github.com/raacampbell/sigstar) — optional, for significance stars in bar plots (`show_mc = 2` or `3`)

## Library Structure

### `libbigtable/` — Per-session result aggregation
Saves per-session analysis results as `.dat` text files, then loads them into a 2D population table (`aPD` array or `tPD` table). Key workflow:

1. **Save per-session results** with `StoreResults(...)` — writes a one-line text row keyed by `unitname`
2. **Load into big table** with `LoadPopulationData5Key` (script, not function) — populates `aPD` and column-name variables in the workspace
3. **unitname format**: `mNsNrNeNuN` (subject/session/run/electrode/unit as 5 numeric keys)
4. Column name variables are auto-generated with a prefix (e.g., `beh_MEAN_GROUP_1`)

### `libpopulation/` — Population plotting + stats
Functions that operate on column vectors from `aPD`. Each plotting function integrates visualization with nonparametric statistical tests (Wilcoxon rank-sum, signed-rank, Spearman correlation) by default. Key functions:
- `plot_scatter`, `plotsqscatter` — scatter with correlation
- `plot_histgrp`, `plot_histsig` — histograms with group comparisons
- `plot_bargrp`, `plot_barpair` — bar graphs with significance markers
- `plot_xygrp`, `plot_xmygrp`, `plot_mxmygrp` — line/tuning curve plots
- `test_same_dist` — standalone statistical comparison
- `is_sk_member`, `is_uk_member` — filter cells by subject/unit membership

### `libtimeseries/` — Trial-aligned time course (PSTH) analysis
Core function is `plot_timecourse`, which plots raster + PSTH aligned to an event and returns a `psth` struct. Key workflow:

1. **Plot/compute**: `plot_timecourse('timestamp'|'stream', data, event, t_start, t_end, ...)`
2. **Save**: `asave_psth(psth, filepath)`
3. **Load multiple**: `load_psth_files(...)` / `load_psth_fpaths(...)`
4. **Filter**: `filter_psth`, `filter_psth_by_cond`, `filter_psth_group`
5. **Homogenize**: `homogenize_psths` — aligns PSTHs with different time ranges
6. **Population plots**: `plot_mpsths`, `plot_mpsth_xneuron`, `plot_mpsth_xsubject`

`psth` struct key fields: `x` (timepoints), `mean` [groups×timepoints], `sem`, `pDiff`, `pBaseDiff`, `event`, `rate_rsp` [trials×timepoints], `ginfo`

### `libss/` — State space analysis
Operates on TCN (Time × Condition × Neuron) or TNC arrays. Functions: `TCN2ss`, `psth2ss`, `analyze_state_space`, `plot_TCN`, `plot3_TCN`. Also includes photometry preprocessing (`preprocess_photometry`, `get_photometry_baseline`).

### `libff/` — (Deprecated/experimental) Additional state space tools

### `libutil/` — Utility functions
- `create_figure`, `setfig`, `setpanel` — figure layout helpers
- `gna` — get next axis
- `atitle`, `add_title` — axis title helpers
- `LoadDefs` pattern — caches declaration scripts in global `gC` to avoid repeated slow loads (see `LoadDefs_example.m`)
- `asave`, `asave_var_as` — save figure/variable helpers
- `process_varargin` — key-value option parsing used throughout the toolbox

## Data Conventions

- **Analysis folder structure**: `{DATA_ROOT}/{subject_id}/{result_files}.dat` and `.mat`
- **Result files**: `.dat` text files (tab/comma delimited), first column always `unitname`
- **PSTH files**: `.mat` files containing `psth` struct
- When multiple results share the same unitname, the **last** one is used by `LoadPopulationData5Key`
- Missing values are represented as `NaN`

## Options Pattern

Most functions accept key-value options via `process_varargin`. To discover all options, open the function and read the first few lines where defaults are defined with `process_varargin`.

## Demo Files

- `demo/demo_analysis_framework.m` — end-to-end pipeline (bigtable → population → timeseries)
- `libtimeseries/demo_timecourse_data_analysis.m` — PSTH workflow
- `libpopulation/demo_population_analysis_functions.m` — population plot functions
- `libbigtable/demo_save_results_load_bigtable.m` — save/load workflow
