function [psth_in psth_out] = filter_psth_trials(st, varargin)
% filter trials in psth (psth.rate_rsp)
% or regular expression for string-match. % explicit list should be the first argument.
%
% 5/20/2018 HRK
error('not implemented yet');
verbose = 1;
% n_grp = NaN;

% lo_varargin = process_varargin(varargin);
lo_varargin  = varargin;

% sort PSTHs
[flist cPSTH] = sort_psth_structs(st);

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