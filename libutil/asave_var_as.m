function asave_var_as(fpath, psth, savename, varargin)
% save a variable (psth) as different name (savename) with an automatic append option.
% 2020 HRK. started 2016

% save_raw = 0;
% check_id = 1;   % check id convention

process_varargin(varargin);

% assign the psth to the designated name
eval( [savename ' = psth;'] );
% save it to file
asave(fpath, savename); 
