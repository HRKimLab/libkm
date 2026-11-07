function [avg_psth psths h_psth] = plot_multiple_psths(cPSTH, c_unitkey, varargin)
% call new function
[avg_psth psths h_psth] = deal([],[],[]);

cPSTH = cell2psths(cPSTH, c_unitkey)
plot_mpsths(cPSTH, varargin{:});