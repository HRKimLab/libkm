% A demo of Matlab functions for exploratory population data analysis
% This demo consists of two part. The first partintroduces a number of
% plotting functions. What makes these functions useful is 1) they show 'N' 
% for data verification and ignores NaNs. 2) perform basic computation (e.g., 
% linear regression) and statistics (e.g., signed rank test) related to the plots.
% 3) additional options makes them strong and flexble. Open each
% function to see a list of available options.
% The second part shows how to load population data. The loading functions
% generate a gigantic 2D array of [entity * features], where entities are either
% neurons or subjects, and features are columns in the text file containing
% numeric data. The first column of text file should be dataname. The text file 
% is assumed to be saved with a specific folder structure. So you may need
% to work on changing folder structure if you want to use this framework.
% Once data is loaded in the gigantic 2D array form, it goes well with the 
% plotting functions in the first part.
% 
% see also DEMO_TIMECOURSE_DATA_ANALYSIS, DEMO_SAVE_SU_RESULTS 

% 3/15/2014 HRK.

%% first part.

% generate x, y, and group (e.g, animal id)
x = randn(100, 1); x_sig = abs(x)
y = x * 2 + randn(100,1);
z = x * 0.5 + rand(100,1);
grp = round(rand(100,1) * 3);

%% scatterplots and basic stats
setfig(2,3);
% plot x and y scatter 
gna; plot_scatter(x,y);
% plot x and y scatter with the same scale
gna; plotsqscatter(x,y);
% show groups
gna; plotsqscatter(x,y, grp,'marker_size', 3);
% use smaller range. # of outliers are shown
gna; plotsqscatter(x,y, grp, 'xl', [-2 2],'marker_size', 3);
% let's say on data point is NaN.
x(1) = NaN;
gna; plotsqscatter(x,y, grp,'marker_size', 3);
% use type 1 regression. check output arguments
gna; [r,p,N,sl,itc,fitdata,pSR, hS] = plotsqscatter(x,y, grp, 'regress_type', 'type1','marker_size', 3)

%% histograms
a = x + 1; b = y + 1; c = b + 2;

setfig(1, 2);
% significance
gna; plot_histsig(a, abs(a)>2);
% groups
gna; plot_histgrp(a, grp, -3:.25:3, 0.5);

%% bar plots with basic stats
setfig(2,2);

[v g] = cols2grp(a, 1, b, 2, c, 3);
% unpaird bar plots
gna; plot_bargrp(v, g, 'show_mc', 3);
% paired bar plots
gna; plot_barpair([a b], [abs(a)>2 abs(b)>2.5]);
% show referenc line and stats
gna; plot_barpair([a b], [abs(a)>2 abs(b)>2.5], 0);
% parametric test
gna; plot_barpair([a b c], [abs(a)>2 abs(b)>2.5 abs(c)>2.5], 0, 'test_type','par');

