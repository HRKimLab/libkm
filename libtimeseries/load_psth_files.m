function [comb, mid_list, cMissing, cInvPSTH] = load_psth_files(filename, mids, varargin)
% combine mat results files saved using save_key() function
% varargin are filters. psths are filtered for each file during iteration
% to save memory
% see load_all_psths() for another version
%  7/9/2015
verbose = 0;
analysis_root = '';

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
    
global gC; % ANALYSIS_ROOT
if ~isempty(gC) && isfield(gC, 'ANALYSIS_ROOT')
    ANALYSIS_ROOT = gC.ANALYSIS_ROOT; 
end
comb = struct;
mid_list = [];
fpaths = {};
cMissing = {};

% if ~is_arg('psth_filter')
%     psth_filter = [];
% end

% if is_arg('repo')
%     ANALYSIS_ROOT = [EXP_ROOT(repo) 'Analysis' filesep];
% end

if ~isempty(analysis_root)
    ANALYSIS_ROOT = analysis_root;
end

% prepare directories for each animal
if is_arg('mids')
    for iM = 1:length(mids)
        fpaths{iM} = [ANALYSIS_ROOT num2str(mids(iM)) '\' filename];
    end
end

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

    % filter out psths before combining to save memory
    if numel(leftover_varargin) > 0
       d = filter_psth(d,  'verbose', 0, leftover_varargin{:});
    end
    
    fn = fieldnames(d);
    
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
            % comb.(fn{iFD}) = [comb.(fn{iFD}); d.(fn{iFD})];
        end
    end
end

cDataname = {};
nDataname = NaN;

% check if filter is specified dataname
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

% verbose info
if verbose
    print_psths_info(comb);
end