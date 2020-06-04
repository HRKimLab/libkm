function [comb, mid_list, cMissing] = load_psths(repo, filename, mids, varargin)
% load psths from multiple animals based on a reserved folder structure
% added repo and make it more modular
% 4/18/2020 HRK
% started 7/9/2015, 

verbose = 0;
check_psth = 1;  % check if it is valid psth structure. off for loading fitting results

cLeft = process_varargin(varargin);

VirMEn_Path_Def;
fpaths = {};
cMissing = {};
comb = struct;
mid_list = [];

% if ~is_arg('psth_filter')
%     psth_filter = [];
% end

if is_arg('repo')
    ANALYSIS_ROOT = [EXP_ROOT(repo) 'Analysis' filesep];
else
    ANALYSIS_ROOT = [DATA_ROOT 'Analysis' filesep];
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
    if ~exist(filepath,'file')
        if verbose
            fprintf(1, 'cannot find file %s\n', filepath);
        end
        continue; 
    end
    d = load(filepath);
    if verbose
        fprintf(1, 'Found psth file %s\n', filepath);
    end

    % skip loading uncecessary fields
    if isfield(d, 'key_list'), d = rmfield(d, 'key_list');    end
    if isfield(d, 'data_list'), d = rmfield(d, 'data_list');   end

    % filter out psths before combining to save memory
    if check_psth && numel(cLeft) > 0
       d = filter_psth(d,  'verbose', 0, cLeft{:});
    end
    
    fn = fieldnames(d);
    
    % iterate field and merge across files
    for iFD = 1:length(fn)
        
        % skip if it is not correct psth structure
        if check_psth && ( ~isfield(d.(fn{iFD}), 'x') || ~isfield(d.(fn{iFD}), 'mean') )
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
for iA = 1:length(cLeft)
    if iscell(cLeft{iA}) && all( cellfun(@isstr, cLeft{iA} ) )
        cDataname = cLeft{iA};
        nDataname = numel( cLeft{iA} );
    end
end


% print out # info
[~,fn] = fileparts(filename);
comb_fn = fieldnames(comb);
if isnan(nDataname)
    fprintf(1, 'combined psths (%s) from %d Subjects, out (%d)\n', fn, numel(mids), numel(comb_fn));
else
    cMissing = setdiff(cDataname, comb_fn);
    fprintf(1, 'combined psths (%s) from %d Subjects, filters (%d), out (%d) \n', fn, numel(mids), nDataname, numel(comb_fn));
    if numel(cMissing) > 0
        fprintf(1, 'missing psths: %s', sprintf('%s ', cMissing{:}) ); fprintf(1, '\n');
    end
end

% verbose info
if verbose && check_psth
    print_psths_info(comb);
end