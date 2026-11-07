function ginfo = params2grp(params, bVT, varargin)
% PARAMS2GRP create group information (ginfo) from candidate experimental conditions.
%  PARAMS2GRP(params) params is a struct containing experimental conditions as a subfield.
%  
%  PARAMS2GRP(params, bVT) bVT is a logical vector whos value is true for 
%    a valid trial. if bVT is given, it ignores invalid trials.
%
%  See EXAMPLES for more options.
%
% EXAMPLES:
% params2grp(params, bVT, 'use_this_params', {'CUE_ON', 'REW_ON'} ) forces
%   the param2grp to include CUE_ON and REW_ON parameters when creating
%   ginfo. Note that use_this_params should be a SUPERSET of varying
%   parameters in 'params'. Otherwise, since you will miss some meaningful
%   parameters, it will produce an error.
% 
% params2grp(params, bVT, 'use_this_params', {'CUE_ON', 'REW_ON'}, 'use_this_values', [1 1; 1 0; 0 0]) 
%   In addition to the above option, it forces to use a fixed set of unique
%   group values to create ginfo and assign grp_idx. This is useful when
%   your experiment sessions have a subset of total experimental
%   conditions.
%   Note that [1 1; 1 0; 0 0] should be a superset of all unique parameter
%   values in the dataset. Otherwise, since you will miss some conditions, 
%   it will generater an error.
%  
% See also data_params2grp
%
% 2017 HRK

use_this_params = {};   % [1 * nParamOfInterest]        cell array of param names
use_this_values = [];   % [nCond * nParamOfInterest]    array values used for assigning fixed gids

process_varargin(varargin);

cP = fieldnames(params);
nP = length(cP);
DynParams = [];
DynArray = [];
DynParams_use_this = []; % for use_this_params
DynArray_use_this = [];  % for use_this_params

if ~is_arg('bVT');
    bVT = true(size(params.(cP{1})));
end
nTrial = length(bVT);

% make it to cell if use_this_params is a single string
if isstr(use_this_params), use_this_params = {use_this_params}; end
if ~isempty(use_this_params)
    n_use_this_param = numel(use_this_params);
    % make sure that it is unique 
    assert(numel( unique( use_this_params ) ) == n_use_this_param, ...
        'use_this_params (%s) should be a set of unique params', ...
        sprintf('%s ', use_this_params{:}) );
    
    % make sure that it is included in the variable list
    bVM = ismember(use_this_params, cP);
    cannot_use_this_params = use_this_params(~bVM);
    assert(n_use_this_param == sum(bVM), ...
        'Some element of use_this_param (%s) is not included in parameter names(cP)', ...
        sprintf('%s ', cannot_use_this_params{:}) );
end

if ~isempty(use_this_values)
   assert(~isempty(use_this_params), 'use_this_params should be given when using use_this_values');
   
   assert(n_use_this_param == size(use_this_values, 2), ...
       '# of columns in use_this value(%d) should match with # in use_this params(%d)', ...
       size(use_this_values, 2), n_use_this_param);
end

% detect paramsters that vary across trials
for iP = 1:nP    
    % # of trials should be same
    assert( length(params.(cP{iP})) == nTrial, '# of trials should be same across params');
    
    % add to dynamic params if # of non-NAN values are greater than one
    if nunique(params.(cP{iP})(bVT) ) > 1
        DynParams = [DynParams cP(iP)];
        DynArray = [DynArray params.(cP{iP})];
    end 
    
    % if use_this_params is given, construct another variable solely based on the list.
    % this will overwrite DynParams and DyaArray after error checks.
    if ~isempty(use_this_params) && any( ismember(use_this_params, cP{iP}) )
        DynParams_use_this = [DynParams_use_this cP(iP)];
        DynArray_use_this = [DynArray_use_this params.(cP{iP})];
    end
end

% DynParams should be a subset of Dynparans_use_this
DynParams_remaining = setdiff(DynParams, DynParams_use_this);
if ~isempty(use_this_params) && ~isempty(DynParams_remaining)
   error('parameter(%s) is varied in this dataset but is not included in use_this_params(%s)', ...
       sprintf('%s ', DynParams_remaining{:}), sprintf('%s ', use_this_params{:}) );
end

% error check is done. overwrite DynParams and DynArray.
if ~isempty(use_this_params)
    DynParams = DynParams_use_this;
    DynArray = DynArray_use_this;
    
    % note that DynParams_use_this is in the order of cP. this is 
    % index of use_this_params in cP order.
    [~, idx_params_in_cP] = ismember(use_this_params, DynParams_use_this);
    use_this_params_sb_cP = use_this_params(idx_params_in_cP);
end

%% Now DynParams and DynArray is made. 
% analyze unique set of parameter values, and assign group id to each parameter set.

if numel(DynParams) == 1 && strcmp(DynParams{1}, 'REWARD_DELAYED_ON_TIME')
%     input(sprintf('REWARD_DELAYED_ON_TIME is varying (%d)... continue ? [y/n]
    log4m.getLogger().warn('param2grp', 'REWARD_DELAYED_ON_TIME is varying (%d)..', nunique(DynArray) );
    DynParams = []; DynArray = [];
end

if isempty(DynArray) && all(bVT == false) % no valid trials
    ginfo.grp = NaN(size(bVT)); ginfo.grp_idx = NaN(size(bVT));
    ginfo.grp_label = {};
    ginfo.unq_grp = [];
    ginfo.unq_grp_label = {};
    ginfo.unq_grp_n = 0;
    return;
elseif isempty(DynArray)
    DynArray = ones(size(params.(cP{1})));
    DynArray(~bVT) = NaN;
    DynParams = {'Same'};
end

% make the trial invalid if all params are NaN
bVT = bVT & ~all(isnan(DynArray), 2);
% get unique conditions
[unq_grp n_cond] = munique(DynArray(bVT,:));
% noticed that the order of unq_grp is not constant.
[~, iS] = sortrows(unq_grp);
unq_grp = unq_grp(iS,:);
n_cond = n_cond(iS, :);

% if use_this_values is given, make sure that given condition # is greater
% than the that of the current dataset.
if ~isempty(use_this_values)
    n_cond_use_this_values = size(use_this_values, 1);
    
    if size(unq_grp, 1) > n_cond_use_this_values
        error('# of conditions in use_this_value(%d) < # of conditions here(%d)', ...
            n_cond_use_this_values, size(unq_grp, 1) );
    end

    % make sure that this session's group is a subset of the use_this_values condition array.
    % note that unq_grp is in the order of cP.
    % to compare DynArray, we need to resort the columns of use_this_values
    % based on the use_this_params in DynParams_use_this order.
    bVM = ismember(unq_grp, use_this_values(:, idx_params_in_cP), 'row');
    if ~all(bVM)
        if ~all( sort(idx_params_in_cP) == idx_params_in_cP)
            disp('Note that COLUMN ORDER is DIFFERENT from use_this_params!!');
        end
        fprintf('some group in the dataset: %s\n', sprintf('%s ', use_this_params_sb_cP{:}) );
        disp(unq_grp(~bVM,:));
        fprintf('is not included in use_this_values: %s \n', sprintf('%s ', use_this_params_sb_cP{:}) );
        
        disp(use_this_values(:, idx_params_in_cP))
        error('This should be fixed');
    end

    % now, error check is done. assign unq_grp and n_cond
    unq_grp = use_this_values(:, idx_params_in_cP);
    n_cond = zeros(size(unq_grp, 1), 1);
    
    for iR = find(bVT')
        bVRow = ismember(unq_grp, DynArray(iR,:),'row');
        assert(sum(bVRow) == 1, 'parameter values (%s) is not included in unq_grp', ...
            sprintf('%.1f ', DynArray(iR,:)) );
        
        % increase count in the corresponding condition
        n_cond(bVRow) = n_cond(bVRow) + 1;
    end
end

if size(unq_grp, 1) > 50
    log4m.getLogger().warn('params2grp', '# of experimental variables >= 50')
end

% get grp_idx and unique group label
unq_grp_label = {};
grp_idx = NaN(size(DynArray,1), 1);
for iR = find(bVT);
   [a grp_idx(iR,1)] = ismember(DynArray(iR, :), unq_grp, 'rows');
end
for iR = 1:size(unq_grp, 1)
    unq_grp_label{iR, 1} = [];
    % generate group labels
    for iC = 1:size(DynArray,2)
        unq_grp_label{iR, 1} = [unq_grp_label{iR, 1} sprintf('%s=%s ', var2abbr(DynParams{iC}), num2str_short( unq_grp(iR,iC) ) )];
    end
    % eliminate last ' '
    unq_grp_label{iR, 1} = unq_grp_label{iR, 1}(1:end-1);
end

cP = cellfun(@var2abbr, DynParams,'un',false);
sParams = sprintf('%s ', cP{:});

% assign results to ginfo
ginfo.grp = DynArray;
ginfo.grp_idx = grp_idx;
ginfo.grp_label = DynParams;
ginfo.unq_grp = unq_grp;
ginfo.unq_grp_label = unq_grp_label;
ginfo.unq_grp_n = n_cond;
ginfo.sParams = sParams;

return