% DEMO_POPULATION_ANALYSIS_FUNCTIONS A demo shoing custom-made functions for population data analysis
% What makes these functions useful is 1) they show 'N' 
% for data verification and ignores NaNs. 2) perform basic computation (e.g., 
% linear regression) and statistics (e.g., signed rank test) related to the plots.
% 3) additional options makes them strong and flexble. 
% Open each function to see a list of available options.
% 
% see also DEMO_POPULATION_ANALYSIS_FRAMEWORK, DEMO_TIMECOURSE_DATA_ANALYSIS, DEMO_SAVE_SU_RESULTS 
%
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
% stack insignificnat and significant data
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

%% X-Y plots 

setfig(2,2);
% x and y are paired column vectors. 
% x is discrete independent variable. 
x = repmat( (1:5)', [20 1])
% y is measurement with noise.
y = x.^2 + randn(size(x)) * 10;
gna;
% plot x and y with error bars
plot_xyerr(x,y, 'errbar_type','patch');

n_trial = numel(x);
grp = randsample([1 2], n_trial, true)';
gna;
% plot x and y for each group
plot_xygrp(x, y, grp);

gna;
% x is 
x = 1:10;
n_trial = 40;
mx = repmat(x, [n_trial, 1]);
my = mx .^ 2 + randn(size(mx)) * 30;
% plot x and matrix y with error bars (no group)
plot_xmyerr(x, my, 'errbar_type','patch');

gna;
% assign group id randomly for each row
grp = randsample([1 2], n_trial, true)';
% plot x and matrix y with group.
plot_xmygrp(x, my, grp);