function [dnames mids sids] = get_datanames(tD, data_tags, varargin)
% GET_DATANAMES retrieve datanames from data tags of the data table.
% GET_DATANAMES(tD, data_tags) tD is a loaded data table from 
% load_tabular_dataset_info(). data_tags is search keywoard for the data
% tags. If it is string, it finds out all data tags that contains the string.
% More specifically, it uses regular expression to find matched data tags.
% If data_tags is a cell array, it combines data_tags from individual
% elements.
% 
% GET_DATANAMES(tD, data_tags, varargin)
% 'exact_match': 1 if you want to put ^ and $ at the beginning and end of
%    the dataname, respectively. This ensures that you can do exact match 
% 'check_mid' : 1 (default) - check if mids in dataname match with the mid
%    in the column header. 0 - do not check.
% 
% Examples:
% % load data table into tD
% tD = load_tabular_dataset_info('Z:\data.csv');
% % combine VR_DAY1 datatsets and VR_DAY2 datasets
% datanames = get_datanames(tD, {'VR_DAY1','VR_DAY2'}); 
% % returns the same set. (order might be different)
% datanames = get_datanames(tD, {'VR_DAY[1-2]'});  .
% % returns regular expression for exact match.
% datanames = get_datanames(tD, {'VR_DAY[1-2]'}, 'exact_match', 1);  .
%
% See also load_tabular_dataset_info, get_datanames_col, LoadPopulationData5Key, regexp
%
% 5/25/2018 HRK

exact_match = 0; % for regular expression exact match
check_mid = 1;   % check if mid in dataname matches with mid in the column header

process_varargin(varargin);

ROW_OFF = 2;
COL_OFF = 2;

mids = []; sids = {};

if is_arg('data_tags') && iscell(data_tags)
   tmp_dnames = cellfun(@(x) get_datanames(tD, x, 'check_mid', check_mid), data_tags, 'un', false);
   dnames = cat(2, tmp_dnames{:});
   return;
end

% deal with NO_FILTER
if (ischar(tD) && strcmp(tD, 'NO_FILTER')) || (nargin > 1 && ischar(data_tags) && strcmp(data_tags, 'NO_FILTER'))
    dnames = [];
    return;
end

% convert to cell array if tD is table
if istable(tD)
    % make cell array by putting rownames and columna names
    if isempty(tD.Properties.RowNames) % RowNames can be empty if not unique (see load_tabular_dataset_info)
		iVC = 2:size(tD, 2);
		cD = [tD{:,:}];
	elseif all(strcmp(tD.Properties.RowNames, tD{:,1}))
        iVC = 2:size(tD, 2);
        cD = [tD.Properties.RowNames tD{:, 2:end}];
    else
        iVC = 1:size(tD, 2);
        cD = [tD.Properties.RowNames tD{:,:}];
    end
    
    tD = [{'animal'}, tD.Properties.VariableNames(iVC); cD];
    % remove 'm' if contains
    tD(1,:) = regexprep(tD(1,:), '^m','');
end

if ~iscell(tD), error('first argument should be cell array of tabular dataset'); end;

% return protocol names if no name is given
if ~is_arg('data_tags')
    dnames = tD(ROW_OFF:end,1);
    
    if exact_match
        dnames = cellfun(@(x) ['^' x '$'], dnames, 'un', false);
    end
    return;
end


if isstr(data_tags), data_tags = {data_tags}; end;

% get mouse numeric id
mids = tD(1, :);

% mids should be numbers except the first column
n_mids = [];
for iC = 2:numel(mids)
   if ~isempty(str2num(mids{iC}))
       n_mids(iC) = str2num(mids{iC});
   elseif numel(mids{iC}) > 0 && (mids{iC}(1) == 'm'||mids{iC}(1) == 'M') && ~isempty(str2num( mids{iC}(2:end) ))
       n_mids(iC) = str2num( mids{iC}(2:end) );
   else
        error('First row of %dth column is not animal numbers: %s', iC, mids{iC} );     
   end
end

% add animal # if dataname starts with 's' and ignore comments
for iR = ROW_OFF:size(tD, 1)
    for iC = COL_OFF:size(tD, 2)
        if isempty( tD{iR,iC} ), continue; end;
        
        % add mouse # if omitted
        if tD{iR,iC}(1) == 's'
            tD{iR,iC} = ['m' mids{iC} tD{iR,iC}];
        elseif tD{iR,iC}(1) == 'm'
            % double check that it matches to animal id in column
            mid_ext = sscanf(tD{iR,iC}, 'm%d');
            if check_mid && mid_ext ~= n_mids(iC)
                error('%s (%d, %d) does not match to mid(%d)', tD{iR,iC}, iR, iC, n_mids(iC));
            end
        end
        
        % ignore data that starts from comment
        if tD{iR,iC}(1) == '%',  tD{iR,iC} = ['-' tD{iR,iC}]; end
        % ignore comments. only take the first token
        tD{iR,iC} = strtok(tD{iR,iC}, ', %?');
    end
end

% find proper row in the table
% iR = find(cellfun(@(x) ~isempty(regexp(x, data_tags)), tD(:,1)));
iR = find( ~cellfun(@isempty, regexp(tD(:,1), data_tags)) );

if strcmp(data_tags, 'all')
    dnames = tD(ROW_OFF:end,COL_OFF:end);
    dnames = dnames(:)';
elseif numel(iR) == 0
    error('cannot find the protocol name %s in the 1st column of the table.\n', data_tags{1});
    dnames = {};
else
    % get a subset of table
    dnames = tD(iR, COL_OFF:end); dnames = dnames(:)';
end

if numel(dnames) == 0
    disp('get_datanames: no dataset was selected');
    return;
end

% remove empty dataset
iValidCol = find(cellfun(@(x) ~isempty(x) && x(1) ~= '-', dnames));
dnames = dnames(iValidCol);
    
fprintf(1, '['); fprintf(1, '%s ', data_tags{:}); fprintf(1, ': %s] (n=%d): ', sprintf('%s ',tD{iR, 1}), numel(dnames));
fprintf(1, '%s ', dnames{:});
fprintf(1, '\n');

% get mids and cell array of sids
mids = []; sids = {};
uk = str2unitkey5(dnames');
if isempty(uk)
    return;
end
mids = nonnan_unique(uk(:,1))';
for iM = 1:length(mids)
   mid = mids(iM);
   bV = uk(:,1) == mid;
   sids{iM} = nonnan_unique(uk(bV, 2));
end