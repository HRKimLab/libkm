# A working example of the framework

See demo_analysis_framework.m for examples of loading data using [libbigtable](https://github.com/hkim09/libkm/tree/master/libbigtable), load psths using [libtimeseries](https://github.com/hkim09/libkm/tree/master/libtimeseries), and plot population analysis results using [libpopulation](https://github.com/hkim09/libkm/tree/master/libpopulation).

### result files

| Filename        |    description      |
|-----------------|---------------------|
| exp_param.dat   |   task parameters   | 
| beh.dat         |   behaviors (average lick and running speed quantified by different time windows) |
| fr_norm.dat     |   neural response (fluorometry quantified using different time windows) |

### Folder structure
For integrative data management, libkm toolbox recommends that analysis result files are stored in a hierarchical folder structure.

Analysis root --- subject id --- {result_files}.dat
```
D:/Analysis   ---  241/      ---  exp_param.dat, beh.dat, fr_norm.dat
               |-- 243/       --- exp_param.dat, beh.dat, fr_norm.dat
               |-- 244/       --- exp_param.dat, beh.dat, fr_norm.dat
```

### 
