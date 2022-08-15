%% load data
% recognize valid columns, create variables for convenient column indexing
% using [fileext column] naming convention.
% input:
%        ResultsExt{nResults} = 'sr';
%        ResultsHeader{nResults} = {'CELL','SPon','Veb_min','Vis_min','Veb_max','Vis_max'};
%        ResultsSummary{nResults} = {[TUNING_DIR{MonkOfInterest} 'DirectionTuning3D_Summary.dat']};
%        ResultsMultipleDelims{nResults} = '\t';
% output:
%        aPD
%        pcd_colname
%
% see DEMO_ANALYSIS_FRAMEWORK for examples
% 2/15/2013 HRK
% make sure that MonkOfInterst does not have redundant monkid
assert(numel(MonkOfInterest) == nunique(MonkOfInterest), 'reduandant aniaml id in MonkOfInterest');
nCol = 0; bColumnsLoaded = {}; iColumnsLoaded = {}; nColumnsLoaded=[]; bHasUnitKey = [];
pcd_colname = {}; pcd_col2res=[]; aPD=[];

% mid, cellid, runid, eid, uid
KEY_COLS = 1:5;

% first columns are [monkey id, cell id, electrode id, unit id]
% those four columns are unique key for each unit.
nCol = nCol + 1;
cmd_str = ['MonkID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{nCol} = 'MonkID';
nCol = nCol + 1;
cmd_str = ['CellID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{nCol} = 'CellID';
nCol = nCol + 1;
cmd_str = ['RunID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{nCol} = 'RunID';
nCol = nCol + 1;
cmd_str = ['ElectID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{nCol} = 'ElectID';
nCol = nCol + 1;
cmd_str = ['UnitID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{nCol} = 'UnitID';

nPreDefinedColumns = nCol;

%% iterate result formats and generate column index for all loaded variables
for iR=1:nResults
    % parse space-seperated header into cell array
    if ischar(ResultsHeader{iR})
        new_header = {};
        [new_header{1} rem] = strtok(ResultsHeader{iR});
        while ~isempty(rem)
            [new_header{end+1} rem] = strtok(rem);
        end
        ResultsHeader{iR} = new_header;
    end
%     
%     % parse file header if it is []
%     if isempty( ResultsHeader{iR} )
%         % automatic loading of header
%         if isstr(ResultsSummary{iR}) && isempty(dir(ResultsSummary{iR}))
%             fpath = [ANALYSIS_ROOT num2str(MonkOfInterest(1)) filesep ResultsSummary{iR}];
%         end
%         if numel(ResultsHeader{iR} ) <= 1
%             
%             fid = fopen(fpath,'r');
%             sHeaderLine = fgets(fid);
%             fclose(fid);
%             
%             nCol = 0;
%             [tok rem] = strtok(sHeaderLine);
%             while ~isempty(rem)
%                 nCol = nCol + 1;
%                 header{nCol} = tok;
%                 [tok rem] = strtok(rem);
%             end
%             
%             ResultsHeader{iR} = header;
%         else
%             
%         end
% 
%     end

    % load columnes except defineds as 'NA' (not available)
    bColumnsLoaded{iR} = cellfun(@(x) ~(strcmp(x, 'NA') | strcmp(x,'FILE') | strcmp(x,'CELL')), ResultsHeader{iR});
    iColumnsLoaded{iR} = find(bColumnsLoaded{iR});
    nColumnsLoaded(iR) = sum(bColumnsLoaded{iR});
    bUnitKey = cellfun(@(x) (strcmp(x,'FILE') | strcmp(x,'CELL')), ResultsHeader{iR});
    bHasUnitKey(iR)    = bUnitKey(1);
    if any( bUnitKey(2:end) )
        error('[%d] FILE or CELL can only be the first column', iR);
    end
    
    fprintf(1, '[%d] %d/%d columns will be loaded\n', iR, length(iColumnsLoaded{iR}), length(bColumnsLoaded{iR}));
    for iC = iColumnsLoaded{iR}
        varname = [ResultsExt{iR} ResultsHeader{iR}{iC}];

        % create index number for each variable
        nCol = nCol + 1;
        cmd_str = [varname ' = ' num2str(nCol) ';'];
        % check variable name redundancy, if loaded for the first time
        %         if ~exist('bVariableLoaded','var') && exist(varname,'var')
        %             error('variable name %s is redundant', varname);
        %         end
        % better version. just check pcd_colname.
        bSameColName = cellfun(@(x) strcmp(x, varname), pcd_colname);
        if any(bSameColName)
            error('adding colunm name %s is redandunt to [%d] column', varname, find(bSameColName,1,'first'));
        end

        eval(cmd_str);
        pcd_colname{nCol} = varname;
        pcd_col2res(nCol) = iR;

        % error check
        % wrong. makes error when loading from seperate files.
%         if ~isempty(ResultsSummary{iR})
%             if ~(strcmp(ResultsHeader{nResults}{1},'FILE') || strcmp(ResultsHeader{nResults}{1},'CELL'))
%                 error('First column of accumulated data file should be FILE (m%dc%dr%d)');
%             end
%         end
    end
end

% check that variables are already loaded.
bVariableLoaded = 1;
% compute number of columns accumulated up to the previous column
nColumnsAccumulated = nPreDefinedColumns + [0 cumsum(nColumnsLoaded(1:end-1))];

% create one row stuffed with NaN to avoid error in searching keys. will be
% deleted later.
aPD = NaN(1, nCol);

% error check
if any(cellfun(@isempty, ResultsSummary))
    warning('ResultsSummary is empty');
    return;
end

%% load population data
for iR=1:nResults
    % seperated multiple data files. load files from directory
    if ( iscell(ResultsSummary{iR}) && isdir(ResultsSummary{iR}{1})  ) || ...
        (ischar(ResultsSummary{iR}) && (ResultsSummary{iR}(end) == '/' || ResultsSummary{iR}(end) == '\') )

        for iM=1:length(MonkOfInterest)
            % make filename. if ext doesn't include '.', it's an extension.
            if isempty(findstr(ResultsExt{iR}, '.'))
                fname = ['*.' ResultsExt{iR}];
            else % otherwise, it is concatenated following the filename (e.g., '_rm.mat')
                fname = ['*' ResultsExt{iR}];
            end
            if (ischar(ResultsSummary{iR}) && (ResultsSummary{iR}(end) == '/' || ResultsSummary{iR}(end) == '\') )
                fdir = [ANALYSIS_ROOT filesep num2str(MonkOfInterest(iM)) filesep ResultsSummary{iR}];
            else
                fdir = ResultsSummary{iR}{iM};
            end
            flist = dir([fdir fname]);
            
            for iF=1:length(flist)
                % extract unitkey
                [nkey monkid cellid runid electid unitid] = ExtractUnitInfo(flist(iF).name);
                nkey5 = [monkid cellid runid electid unitid];
                % check if data is of my interest
                iMonkNo = find(monkid == MonkOfInterest);
                if isempty(iMonkNo), continue; end
                iCellNo = find(cellid == CellOfInterest{iMonkNo});
                if isempty(iCellNo), continue; end
                
                % check subject
                iIncorrectSubject = find(nkey5(:,1) ~= MonkOfInterest(iM));
                if ~isempty(iIncorrectSubject)
                    error('%s: Some data have incorrect subject number (%d in the directory for %d)',...
                        ResultsSummary{iR}{iM}, nkey5(iIncorrectSubject(1),1), MonkOfInterest(iM));
                end

                % load one cell data
                fprintf(1, 'load %s\n', flist(iF).name);
                
                if 0 % is_arg('TCMatInfo') && length(TCMatInfo) >= iR && ~isempty(TCMatInfo{iR})
                    if iscell(ResultMatInfo{iR})    % multiple variables in .mat file

                    elseif isstr(ResultMatInfo{iR}) % single variable in .mat file
                        tmp = load('-mat', [ResultsSummary{iR}{iM} flist(1).name], ResultMatInfo{iR});
                        all_columns_data = tmp.(ResultMatInfo{iR});
                        % the data should be an array of (column #) * 1
                        assert(size(all_columns_data,1) == 1, '.mat file (%s/%s) has more than a single row ', ...
                            [ResultsSummary{iR}{iM} flist(1).name], ResultMatInfo{iR});
                    else % some other .mat file loading methods
                    end
                else % text file
                    all_columns_data = dlmread([fdir flist(iF).name]);
                    if size(all_columns_data,1) > 1
                        warning('%s has more than one row. Use the last row', [fdir flist(iF).name]);
                        all_columns_data = all_columns_data(end,:);
                    end
                end
                
                % number of data columns in header and file should be same.
                if size(all_columns_data,2) ~= (length(bColumnsLoaded{iR} - bHasUnitKey(iR)))
                    error('size of header for ext(%s;%d) and data from file (%s;%d) do not match', ...
                        ResultsExt{iR}, length(bColumnsLoaded{iR}), flist(iF).name, size(all_columns_data,2));
                end

                for iRow = 1:size(nkey5,1)
%                     bSameNeuron = nkey(iRow,1) == aPD(:,MonkID) & nkey(iRow,2) == aPD(:,CellID) & ...
%                         nkey(iRow,3) == aPD(:, ElectID) & nkey(iRow,4) == aPD(:, UnitID);
                    bSameNeuron = all( bsxfun(@minus, nkey5(iRow, :), aPD(:, KEY_COLS) ) == 0, 2);
                    if nnz(bSameNeuron) > 1,
                        error('duplicate neuron key: %s', sprintf('%d ', nkey5));
                    end;

                    if any(bSameNeuron) % existing neuron key. update the row
                        % check there is already from same datafile
                        if any( ~isnan(aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) )
                            warning('Data already exist in %s {m%dc%dr%de%du%d}(%d, %d-%d). Overwrite it', ...
                                fdir, nkey5(iRow,1),nkey5(iRow,2),nkey5(iRow,3),nkey5(iRow,4), nkey5(iRow,5), iRow, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                        end
                        % update data.
                        aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-bHasUnitKey(iR));
                    else % new neuron key. inser a row
                        onerow = NaN(1, nCol);
                        onerow(KEY_COLS) = nkey5(iRow,:);
                        % update the inserted row
                        onerow(nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-bHasUnitKey(iR));
                        aPD(end+1,:) = onerow;
                    end
                end
            end
        end
        % accumulated data file for each subject
    elseif iscell(ResultsSummary{iR}) || ...
            ( isstr(ResultsSummary{iR}) && isempty(dir([ResultsSummary{iR}])) && isempty(findstr(ResultsSummary{iR}, ':')) )
        
        
        for iM=1:length(MonkOfInterest)
            
            % relative path
            if ( isstr(ResultsSummary{iR}) && isempty(dir([ResultsSummary{iR}])) && isempty(findstr(ResultsSummary{iR}, ':')) )
                fpath = [ANALYSIS_ROOT filesep num2str(MonkOfInterest(iM)) filesep ResultsSummary{iR}];
            else
                fpath = ResultsSummary{iR}{iM};
            end
            
            if isempty(dir(fpath))
                warning('Cannot find file %s', fpath);
                continue;
            end
            
            [all_columns_data nkey nkey5] = ReadCellDataKey(fpath, ResultsHeader{iR}, 1, ResultsMultipleDelims(iR));
            % check subject
            iIncorrectSubject = find(nkey5(:,1) ~= MonkOfInterest(iM));
            if ~isempty(iIncorrectSubject)
                error('%s: Some data have incorrect subject number (%d in the directory for %d)',...
                    ResultsSummary{iR}{iM}, nkey5(iIncorrectSubject(1),1), MonkOfInterest(iM));
            end
            % from here, it is same as loading a single result file.
            for iRow = 1:size(nkey5,1)
                % check if data is of my interest
                iMonkNo = find(nkey5(iRow,1) == MonkOfInterest);
                if isempty(iMonkNo), continue; end
                iCellNo = find(nkey5(iRow,2) == CellOfInterest{iMonkNo});
                if isempty(iCellNo), continue; end

                bSameNeuron = all( bsxfun(@minus, nkey5(iRow, :), aPD(:, KEY_COLS) ) == 0, 2);
%                 bSameNeuron = nkey(iRow,1) == aPD(:,MonkID) & nkey(iRow,2) == aPD(:,CellID) & ...
%                     nkey(iRow,3) == aPD(:, ElectID) & nkey(iRow,4) == aPD(:, UnitID);
                if nnz(bSameNeuron) > 1, error('duplicate unitkey: %s', sprintf('%d ', nkey)); end;

                if any(bSameNeuron) % existing neuron key. update the row
                    % check there is already from same datafile
                    if any( ~isnan(aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) )
%                         warning('Data already exist in %s {m%dc%de%du%d}(%d, %d-%d). Overwrite it', ...
%                             fpath, nkey(iRow,1),nkey(iRow,2),nkey(iRow,3),nkey(iRow,4), iRow, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                    end
                    % update data.
                    aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-bHasUnitKey(iR));
                    
                else % new neuron key. inser a row
                    onerow = NaN(1, nCol);
                    onerow(KEY_COLS) = nkey5(iRow,:);
                    % update the inserted row
                    onerow(nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-bHasUnitKey(iR));
                    aPD(end+1,:) = onerow;
                end
            end
        end
    % accumulated single data file
    elseif isstr(ResultsSummary{iR})
        % celldata is a cell arrary.
        fprintf(1, 'load %s\n', ResultsSummary{iR});

        % same as above
        [all_columns_data nkey nkey5 header] = ReadCellDataKey(ResultsSummary{iR}, ResultsHeader{iR}, 1, ResultsMultipleDelims(iR));
        
        if numel(ResultsHeader{iR}) == 0, ResultsHeader{iR} = header; end
        
        for iRow = 1:size(nkey5,1)
            % check if data is of my interest
            iMonkNo = find(nkey5(iRow,1) == MonkOfInterest);
            if isempty(iMonkNo), continue; end
            iCellNo = find(nkey5(iRow,2) == CellOfInterest{iMonkNo});
            if isempty(iCellNo), continue; end


%             bSameNeuron = nkey(iRow,1) == aPD(:,MonkID) & nkey(iRow,2) == aPD(:,CellID) & ...
%                 nkey(iRow,3) == aPD(:, ElectID) & nkey(iRow,4) == aPD(:, UnitID);
            bSameNeuron = all( bsxfun(@minus, nkey5(iRow, :), aPD(:, KEY_COLS) ) == 0, 2);
            if nnz(bSameNeuron) > 1, error('duplicate neuron key: %s', sprintf('%d ', nkey)); end

            if any(bSameNeuron) % existing neuron key. update the row
                % check there is already from same datafile
                if any( ~isnan(aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) )
                    warning('Data already exist in %s {m%dc%dr%de%du%d}(%d, %d-%d). Overwrite it', ...
                        ResultsSummary{iR}, nkey5(iRow,1),nkey5(iRow,2),nkey5(iRow,3),nkey5(iRow,4),nkey5(iRow,5), iRow, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                end
                % update data.
                aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-bHasUnitKey(iR));
            else % new neuron key. inser a row
                onerow = NaN(1, nCol);
                onerow(KEY_COLS) = nkey5(iRow,:);
                % update the inserted row
                onerow(nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-bHasUnitKey(iR));
                aPD(end+1,:) = onerow;
            end
        end
    end
end

% delete fist NaN raws
aPD(1,:) = [];

% sort by monk, cell, electrode and unit
[tmp iSortRow] = sortrows(aPD(:, KEY_COLS));
aPD = aPD(iSortRow,:);

bPDBehavior = aPD(:,4) == -1 & aPD(:,5) == -1;
bPDNeuron = ~bPDBehavior;

% also create a table variable from array.
tPD = array2table(aPD, 'VariableNames', pcd_colname);

fprintf(1, 'Data loading to aPD and tPD completed!\n');