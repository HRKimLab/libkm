function [comb, mid_list, cMissing, cInvPSTH] = combine_psths(filename, mids, varargin)
% combine mat results files saved using save_key() function
%  7/9/2015
global gC; struct2var(gC); % VirMEn_Def
comb = struct;
mid_list = [];
fpaths = {};
cMissing = {};
verbose = 0;

% if ~is_arg('psth_filter')
%     psth_filter = [];
% end

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
    d = load(filepath);

    % skip loading uncecessary fields
    if isfield(d, 'key_list'), d = rmfield(d, 'key_list');    end
    if isfield(d, 'data_list'), d = rmfield(d, 'data_list');   end

    % filter out psths before combining to save memory
    if numel(varargin) > 0
       d = filter_psth(d,  'verbose', 0, varargin{:});
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
            warning('Redundant psth found (%s). psth will be overwritten', fn{iD});
            comb.(fn{iFD}) = [d.(fn{iFD})];
            % comb.(fn{iFD}) = [comb.(fn{iFD}); d.(fn{iFD})];
        end
    end
end

cDataname = {};
nDataname = NaN;

% check if filter is specified dataname
for iA = 1:length(varargin)
    if iscell(varargin{iA}) && all( cellfun(@isstr, varargin{iA} ) )
        cDataname = varargin{iA};
        nDataname = numel( varargin{iA} );
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
if verbose
    print_psths_info(comb);
end