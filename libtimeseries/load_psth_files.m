function [comb, mid_list, cMissing, cInvPSTH] = load_psth_files(filename, mids, varargin)
% LOAD_PSTH_FILES load and combine psth .mat files
%   In a single session analysis, time courses are visualized and the
%   results can be saved into .mat file using asave_psth() for each session.
%   For population analysis, These time courses across multiple sessions need to 
%   be loaded and analyzed altogether. load_psth_files iterates files, load them,
%   and combine them such that it can be visualized and analzyed easily.
%   It assumes that psth files are saved in a standard folder structure. 
%
% load_psth_files(filename, mids): load psth files based on the filename
% and mids. Single psth file usually contains multiple psth results from
% one animal. In the standard framework, the psth file is saved in 
% Y:\NeuRLab\Analysis\mid\ 
%
% load_psth_files(filename, mids, varargin) varargin are psth filters. 
%   loading all psths often requires lots of memory. To avoid this, 
%   psth filters can be applied for each .mat, and the results are then
%   combined to save memory. See filter_psth for details about psth filters
%
%   Note: if your computer has enough memory, it is fine to load all psth files
%   without filter (e.g., load all psth data from all animals), and filter 
%   them later using filter_psth (e.g., filter-in experiment 1, do analysis; 
%   filter-in experiments 2, do analysis, and so on). 
%   do this way if you want to use 'load a superset, and then use subsets for
%   each analysis' strategy.
% 
% Examples:
% datanames = {'m123s8r1','m123s9r1','m145s31r1','m145s32r1','m156s13r1','m156s14r1'};
% lick_RewOn = load_psth_files('lick_ab_RewOn.mat', [123 145 156], ...
%    'analysis_root', 'Y:\NeuRLab\Analysis\', datanames);
%
% use load_psth_fpaths to directly specify file paths of psths.
%
% See also FILTER_PSTH, LOAD_ALL_PSTHS, LOAD_PSTH_FPATHS

%  7/9/2015 HRK

verbose = 0;
analysis_root = '';
repo = '';

opt = who();
[leftover_varargin i_left] = process_varargin_ext(varargin);

% make sure that options are on first, and all leftovers are on the right
% side of varargin. This makes sure that I do not mistreat filter or
% accidently miss options.
b_left = false(size(varargin)); 
b_left(i_left) = true;
i_first_left = find(b_left,1,'first');
assert(all(b_left(i_first_left:end)), 'varargin that are not options should appear AFTER options');

% also, make sure that leftover does not include options
for iL = 1:numel(leftover_varargin)
    if isstr(leftover_varargin{iL}) && ismember(leftover_varargin{iL}, opt)
        error('leftover contains options. Options should appear first and should start at even order');
    end
end
    
% % get default ANALYSIS_ROOT
% global gC; 
% % if exists, load declaration script
% if isempty(gC) && exist('VirMEn_Def','file');
%     gC = scriptvar2struct('VirMEn_Def');
% end
%     
% if ~isempty(gC) && isfield(gC, 'ANALYSIS_ROOT')
%     ANALYSIS_ROOT = gC.ANALYSIS_ROOT; 
% end
% 
% % if repo is given, use it
% if ~isempty(repo) && ~isempty(gC) && isfield(gC, 'EXP_ROOT')
%     ANALYSIS_ROOT = [gC.EXP_ROOT(repo) 'Analysis' filesep];
% end

% if given by an agument, use it
if ~isempty(analysis_root)
    ANALYSIS_ROOT = analysis_root;
end

fpaths = {};
% prepare directories for each animal
if is_arg('mids')
    for iM = 1:length(mids)
        fpaths{iM} = [ANALYSIS_ROOT num2str(mids(iM)) '\' filename];
    end
end

comb = struct;
mid_list = [];
cMissing = {};

% load and combine psths files
comb = load_psth_fpaths(fpaths, verbose, leftover_varargin{:} );

% check if one of filters is individual datanams.
cDataname = {};
nDataname = NaN;

for iA = 1:length(leftover_varargin)
    if iscell(leftover_varargin{iA}) && all( cellfun(@isstr, leftover_varargin{iA} ) )
        cDataname = leftover_varargin{iA};
        nDataname = numel( leftover_varargin{iA} );
    end
end

% print out # info
[~,fn] = fileparts(filename);
comb_fn = fieldnames(comb);
if isnan(nDataname)
    fprintf(1, 'combined psths (%s) from %d Subjects, total %d psths\n', fn, numel(mids), numel(comb_fn));
else
    cMissing = setdiff(cDataname, comb_fn);
    fprintf(1, 'combined psths (%s) from %d Subjects, filters (%d), total %d psths\n', fn, numel(mids), nDataname, numel(comb_fn));
    if numel(cMissing) > 0
        fprintf(1, 'missing psths: %s', sprintf('%s ', cMissing{:}) ); fprintf(1, '\n');
    end
end