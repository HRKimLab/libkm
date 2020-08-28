# libkm
A very practical matlab toolbox for behavioral and neural data analyses. This toolbox helps you code less and focus on science.

# How to use
The simplest way is to download the .zip file, uncompress, add folders to Matlab path, and use it. If you want to add new functions or modify existing functions. The best way is to [fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) the master branch to your repository and modify the code. Since the codes in the master branch constantly change, having your own version ensures that your analysis results are secured from those changes. After you submit your paper, you can also [release and tag](https://docs.github.com/en/github/administering-a-repository/managing-releases-in-a-repository) the forked codes such that you have a snapshot of your submitted version. If you would like to use new features, you can compare the difference between the forked version and the master branch, and [pull](https://github.com/git-guides/git-pull) changes with your awareness. 
 
## [libpopulation](https://github.com/hkim09/libkm/tree/master/libpopulation)
Plot data with relevant statistical tests.

## [libtimeseries](https://github.com/hkim09/libkm/tree/master/libtimeseries)
Plot time course and save the results. Combime the results and plot population time courses.

## [libbigtable](https://github.com/hkim09/libkm/tree/master/libbigtable)
Save individual-session analysis results. Load population data into a big table.

## [libutil](https://github.com/hkim09/libkm/tree/master/libutil)
A collection of misc functions.

# Dependencies

- Many functions use process_varargin.m from [MClust](http://redishlab.neuroscience.umn.edu/mclust/MClust.html)
- If opted, plot_timecourse use [panel](https://www.mathworks.com/matlabcentral/fileexchange/20003-panel) for more packed plots
- If opted, bar plots use [sigstar](https://github.com/raacampbell/sigstar) to show nice star marks


#### CHANGELOG (major changes)

8/13/2020 separated data loading and saving related functions into libbigtable 
