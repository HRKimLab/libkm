function [comb, n_psths, n_psths_filtered] = load_psth_fpaths(fpaths, verbose, varargin)
% LOAD_PSTH_FPSTHS load paths from cell array of file paths
% varargin are filters. If given, it applies filters after each loading to save memory
% see also LOAD_PSTH_FILES, LOAD_PSTHS, LOAD_ALL_PSTHS
%
% 9/9/2020 HRK

% TODO: there are too many versions of psth loading functions. I need to clean up 
% some and change other functions such that they call this function.
% this is most primitive loading function. do not have process_varargin in this
% function. make another wrapper function if you need some fancier loading,
% make another function and call this. For other versions,

% verbose can be 0, 1, 2
if ~is_arg('verbose'), verbose = 0; end;

% all varargin should be used for filter in this function.
filter_varargin = varargin;

n_psths = zeros(1, numel(fpaths));
n_psths_filtered = zeros(1, numel(fpaths));
comb = struct;

% iterlate directories for each animal
for iF = 1:length(fpaths)
    filepath = fpaths{iF};
    
    % load psth mat file
    if ~exist(filepath,'file'), continue; end;
    try
    d = load(filepath);
    catch ME
        ME
        errordlg(['loading file failed: ' filepath ])
        continue;
    end

    % skip loading uncecessary fields
    if isfield(d, 'key_list'), d = rmfield(d, 'key_list');    end
    if isfield(d, 'data_list'), d = rmfield(d, 'data_list');   end

    n_psths(iF) = nfields(d);
    % filter-in psths before combining to save memory
    if numel(filter_varargin) > 0
       d = filter_psth(d,  'verbose', verbose, filter_varargin{:});
    end
    
    fn = fieldnames(d);
    n_psths_filtered(iF) = numel(fn);
    
    % iterate field and merge across files
    for iFD = 1:length(fn)
        
        % skip if it is not correct psth structure
        if ~isfield(d.(fn{iFD}), 'x') || ~isfield(d.(fn{iFD}), 'mean')
            continue;
        end
    
        % copy structure fields
        if isempty(comb) || ~isfield(comb, fn{iFD})
            comb.(fn{iFD}) = d.(fn{iFD});
        else
            warning('Redundant psth found (%s). psth will be overwritten', fn{iFD});
            comb.(fn{iFD}) = [d.(fn{iFD})];
        end
    end
end

comb_fn = fieldnames(comb);
fprintf(1, 'combined psths from %d files, total %d psths loaded, filtered-in %d psths\n', ...
    nnz(n_psths > 0), sum(n_psths), nfields(comb) ); % somehow sum(n_psths_filtered) is not correct

% show verbose info
if verbose == 2
    % too verbose...
    print_psths_info(comb);
end