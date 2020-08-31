# A working example of the libkm framework

See demo_analysis_framework.m for examples of population analysis framework. The demo shows examples of loading data using [libbigtable](https://github.com/hkim09/libkm/tree/master/libbigtable), plot population analysis results using [libpopulation](https://github.com/hkim09/libkm/tree/master/libpopulation), and plot time courses using [libtimeseries](https://github.com/hkim09/libkm/tree/master/libtimeseries).

### result files

| Filename        |    description      |
|-----------------|---------------------|
| exp_param.dat   |   task parameters   | 
| beh.dat         |   behaviors (average lick and running speed quantified by different time windows) |
| fr_norm.dat     |   neural response (fluorometry quantified using different time windows) |

### Folder structure
For integrative data management, libkm toolbox recommends that analysis result files are stored in a hierarchical folder structure.

Analysis root --- subject id --- {result_files}.dat; (result_psth).mat

```
D:/Analysis   ---  241/      ---  exp_param.dat, beh.dat, fr_norm.dat, lick_ab_RewOn.mat, loc_ab_RewOn.mat
               |-- 243/       --- exp_param.dat, beh.dat, fr_norm.dat, lick_ab_RewOn.mat, loc_ab_RewOn.mat
               |-- 244/       --- exp_param.dat, beh.dat, fr_norm.dat, lick_ab_RewOn.mat, loc_ab_RewOn.mat
```

### Example plots
