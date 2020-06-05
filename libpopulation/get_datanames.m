function [dnames mids sids] = get_datanames(tD, prot_name)
% get dataset names based on a tabular format of dataset file
% using regular expression
% tD = load_tabular_dataset_info('Z:\data.csv');
% datanames = get_datanames(tD, {'VR_DAY1','VR_DAY2'});
%
% 5/25/2018 HRK
ROW_OFF = 2;
COL_OFF = 2;

mids = []; sids = {};

if is_arg('prot_name') && iscell(prot_name)
   tmp_dnames = cellfun(@(x) get_datanames(tD, x), prot_name, 'un', false);
   dnames = cat(2, tmp_dnames{:});
   return;
end

% deal with NO_FILTER
if (ischar(tD) && strcmp(tD, 'NO_FILTER')) || (nargin > 1 && ischar(prot_name) && strcmp(prot_name, 'NO_FILTER'))
    dnames = [];
    return;
end

if ~iscell(tD), error('first argument should be cell array of tabular dataset'); end;

% return protocol names if no name is given
if ~is_arg('prot_name')
    dnames = tD(ROW_OFF:end,1);
    return;
end


if isstr(prot_name), prot_name = {prot_name}; end;

% get mouse numeric id
mids = tD(1, :);

% mids should be numbers except the first column
n_mids = [];
for iC = 2:numel(mids)
   if isempty(str2num(mids{iC}))
        error('First row of %dth column is not animal numbers: %s', iC, mids{iC} );
   end
   n_mids(iC) = str2num(mids{iC});
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
            if mid_ext ~= n_mids(iC)
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
% iR = find(cellfun(@(x) ~isempty(regexp(x, prot_name)), tD(:,1)));
iR = find( ~cellfun(@isempty, regexp(tD(:,1), prot_name)) );

if strcmp(prot_name, 'all')
    dnames = tD(ROW_OFF:end,COL_OFF:end);
    dnames = dnames(:)';
elseif numel(iR) == 0
    error('No dataset with protocol name %s\n', prot_name{1});
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

fprintf(1, '['); fprintf(1, '%s ', prot_name{:}); fprintf(1, ': %s] (n=%d): ', sprintf('%s ',tD{iR, 1}), numel(dnames));
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