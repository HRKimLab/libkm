function [psth_in psth_out] = filter_psth(st, varargin)
% FILTER_PSTH filter psths and return a subset. 
%   filter_psth(st, varargin) st is a variable that contains psth as fields.
%   varargin is the filtering criteria. these can be the following.
%     cell array: an explicit list of dataname or unitname strings, 
%        e.g., {'m192s23r1','m193s23r2', ... } for behavioral data,
%              {'m183s14r1e3u1','m184s18r1e2r1', ..} for neural data.
%     numeric array: unitkey array (n_filters * 5). 
%         psth will filter-in if it matches to any of the rows.
%         NaN means that such element will be filtered-in
%         e.g., [192 NaN 1 NaN 1; 293 NaN 1 NaN 1] will filter in
%               data from 192 and 293, and rid should be 1, and uid (e.g.,
%               photometry channel) should be 1.
%     string: regular expression for string-match. 
%         e.g., 'm294s[0-9].r1[eu0-9]*' will filter-in data from
%               animal 294, sid 0-9, rid 1. see regular expression (regexp)
%               for more info about how to use this.
%
%   Note that explicit list should be the first argument if you use
%   multiple criteria.
%
% RETURN VALUES:
% [psth_in psth_out] = filter_psth(st, varargin)
% psth_in:      psths that are filtered in.
% psth_out:     psths that are filtered out.
%
% See also LOAD_PSTH_FILES, filter_psth_by_cond, filter_psth_by_n,
%   filter_psth_group, filter_psth_trials, REGEXP
%
% 5/20/2018 HRK

verbose = 1;
% n_grp = NaN;

% lo_varargin = process_varargin(varargin);
lo_varargin  = varargin;

% sort PSTHs. keep the order here for boolean filter
[flist cPSTH] = sort_psth_structs(st, 'no_sort');

bV = true(size(flist));

% iterate filters and perform AND operations
iA = 1;
while iA <= length(lo_varargin)
    if isempty(lo_varargin{iA})
        iA = iA + 1;
        continue; 
    end
    psth_filter = lo_varargin{iA};
    bV1 = true(size(bV));
    
    if iscell(psth_filter) || ( isstr( psth_filter ) && ~strcmp(psth_filter, 'verbose') )
        % filter the list using regular expression
        bV1 = is_sk_member(flist, psth_filter);
    elseif isnumeric( psth_filter ) && numel( psth_filter ) > 1
        % filter the list using numeric unitkey (NaN == all)
        bV1 = is_uk_member(flist, psth_filter);
    elseif ischar( psth_filter ) && strcmp(psth_filter, 'verbose')
        assert( numel( lo_varargin{iA+1} ) == 1, 'verbose parameter should have 1 value (0/1)');
        verbose = double(lo_varargin{iA+1});
        iA = iA+1;
    elseif islogical( psth_filter ) && numel( psth_filter ) == numel(flist) % direct boolean flag
        bV1 = psth_filter(:);
    else
        error('Unknow filter:');
    end
    
    % perform AND operation
    bV = bV & bV1;
    
    iA = iA + 1;
end

% % filter by group number
% if ~isnan(n_grp)
%     for iF = 1:numel(bV)
%        bV(iF) = bV(iF) & size(cPSTH{iF}.mean, 1) == n_grp; 
%     end
% end

iIn = find(bV(:)');
iOut = find(~bV(:)');

% assign psth_in and psth_out structure
psth_in = struct(); psth_out = struct();
for iF = iIn
   psth_in.(flist{iF}) = cPSTH{iF}; 
end
for iF = iOut
    psth_out.(flist{iF}) = cPSTH{iF}; 
end


if verbose
    if iscell(lo_varargin{1}) && numel(iIn) == numel(lo_varargin{1})
        fprintf(1, 'filter_psth: # of filtered psths matches to # of individually requested psths (n=%d): ', numel(iIn));
    else
        fprintf(1, 'filter_psth: filtered psths (n=%d): ', numel(iIn));
        fprintf(1, '%s ', flist{iIn});
    end
    fprintf(1, '\n');
%     
%     % if the first filter contains the name of exact dataset, print out missing dataset.
%     data_missing = setdiff(psth_filter, cellfun(@(x) regexprep(x, 'e[0-9]*u[0-9]*',''), fieldnames(psth_in),'un',false) );
%     if iscell(lo_varargin{1}) && numel(data_missing) > 0
%         psth_filter = lo_varargin{1};
%         fprintf(1, 'dataset missing: ');
%         fprintf(1, '%s ', data_missing{:});
%         fprintf(1, '\n');
%     end 
end