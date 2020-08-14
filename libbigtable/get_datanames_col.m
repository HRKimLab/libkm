function [dnames mids sids] = get_datanames_col(tD, prot_name, b_allow_alternative)
% get_datanames_col: get_datanames(), but with columnar structure
% get dataset names based on a tabular format of dataset file
% using regular expression
% tD = load_tabular_dataset_info('Z:\data.csv');
% datanames = get_datanames(tD, {'VR_DAY1','VR_DAY2'});
%
% 2019 HRK
ROW_OFF = 2;
COL_OFF = 2;

mids = []; sids = {};

% deal with NO_FILTER
if (ischar(tD) && strcmp(tD, 'NO_FILTER')) || (nargin > 1 && ischar(prot_name) && strcmp(prot_name, 'NO_FILTER'))
    dnames = [];
    return;
end

if istable(tD)
%     % make cell array by putting rownames and columna names
%     if all(strcmp(tD.Properties.RowNames, tD{:,1}))
%         iVC = 2:size(tD, 2);
%         cD = [tD.Properties.RowNames tD{:, 2:end}];
%     else
%         iVC = 1:size(tD, 2);
%         cD = [tD.Properties.RowNames tD{:,:}];
%     end
    
%     tD = [{'animal'}, tD.Properties.VariableNames(iVC); cD];
%     % remove 'm' if contains
%     tD(1,:) = regexprep(tD(1,:), '^m','');
%     
    % I am gradually shifting from cell array to table.
    % add header if it is table
    cD = table2cell(tD);
    cD(2:end+1,:) = cD(1:end,:);
    cD(1,:) = tD.Properties.VariableNames;
    tD = cD;
end

if ~iscell(tD), error('first argument should be cell array of tabular dataset'); end;

% return protocol names if no name is given
if ~is_arg('prot_name')
    dnames = tD(1, COL_OFF:end);
    return;
end


if isstr(prot_name), prot_name = {prot_name}; end;

% get numeric id
mids = tD(:, 1);

% mids should be numbers except the first column
n_mids = [];
for iR = ROW_OFF:numel(mids)
   if isempty(str2num(mids{iR}))
        error('First column of %dth row is not numeric id: %s', iR, mids{iR} );
   end
   n_mids(iR) = str2num(mids{iR});
end

% add animal # if dataname starts with 's' and ignore comments
for iR = ROW_OFF:size(tD, 1)
    for iC = COL_OFF:size(tD, 2)
        if isempty( tD{iR,iC} ), continue; end;
        
        % add mouse # if omitted
        if tD{iR,iC}(1) == 's'
            tD{iR,iC} = ['m' mids{iR} tD{iR,iC}];
        elseif tD{iR,iC}(1) == 'm'
            % double check that it matches to animal id in column
            mid_ext = sscanf(tD{iR,iC}, 'm%d');
            if mid_ext ~= n_mids(iR)
                error('%s does not match to mid(%d)', tD{iR,iC}, n_mids(iR));
            end
        end
        
        % ignore data that starts from comment
        if tD{iR,iC}(1) == '%',  tD{iR,iC} = ['-' tD{iR,iC}]; end
        % ignore comments. only take the first token
        tD{iR,iC} = strtok(tD{iR,iC}, ', %?');
    end
end

% find proper column in the table
% iR = find(cellfun(@(x) ~isempty(regexp(x, prot_name)), tD(:,1)));
iC = find( ~cellfun(@isempty, regexp(tD(1, :), prot_name)) );

if strcmp(prot_name, 'all')
    dnames = tD(ROW_OFF:end,COL_OFF:end);
    dnames = dnames(:)';
elseif numel(iC) == 0
    error('No dataset with protocol name %s\n', prot_name{1});
    dnames = {};
else
    % get a subset of table
    dnames = tD(ROW_OFF:end, iC); dnames = dnames(:)';
end

if numel(dnames) == 0
    disp('No dataset was selected');
    return;
end

% remove empty dataset
iValidCol = find(cellfun(@(x) ~isempty(x) && x(1) ~= '-', dnames));
dnames = dnames(iValidCol);

fprintf(1, '['); fprintf(1, '%s ', prot_name{:}); fprintf(1, ': %s] (n=%d): ', sprintf('%s ',tD{iR, 1}), numel(dnames));
fprintf(1, '%s ', dnames{:});
fprintf(1, '\n');

% get mids and cell array of sids
mids = []; sids = {};
uk = str2unitkey5(dnames');
if isempty(uk)
    return;
end
mids = unique(uk(:,1))';
for iM = 1:length(mids)
   mid = mids(iM);
   bV = uk(:,1) == mid;
   sids{iM} = unique(uk(bV, 2));
end