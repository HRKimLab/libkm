% demo for photometry preprocessing routine
% load data
load('example_photometry_signal.mat');
% set debug to 1 to visualize how it the signal is processed
preprocess_photometry( rawG, rawR, 'debug', 1);