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
nCol = 0; bColumnsLoaded = {}; iColumnsLoaded = {}; nColumnsLoaded=[];
pcd_colname = {}; pcd_col2res=[]; cPD={}; aPD=[];

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
cmd_str = ['ElectID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{nCol} = 'ElectID';
nCol = nCol + 1;
cmd_str = ['UnitID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{nCol} = 'UnitID';

nPreDefinedColumns = nCol;

% iterate result formats and generate column index for all loaded variables
for iR=1:nResults
    % load columnes except defineds as 'NA' (not available)
    bColumnsLoaded{iR} = cellfun(@(x) ~(strcmp(x, 'NA') | strcmp(x,'FILE') | strcmp(x,'CELL')), ResultsHeader{iR});
    iColumnsLoaded{iR} = find(bColumnsLoaded{iR});
    nColumnsLoaded(iR) = sum(bColumnsLoaded{iR});
    fprintf(1, '[%d] %d/%d columns will be loaded\n', iR, length(iColumnsLoaded{iR}), length(bColumnsLoaded{iR}));
    for iC = iColumnsLoaded{iR}
        varname = [ResultsExt{iR} ResultsHeader{iR}{iC}];

        % create index number for each variable
        nCol = nCol + 1;
        cmd_str = [varname ' = ' num2str(nCol) ';'];
        % check variable name redundancy, if loaded for the first time
        if ~exist('bVariableLoaded','var') && exist(varname,'var')
            error('variable name %s is redundant', varname);
        end
            
        eval(cmd_str);
        pcd_colname{nCol} = varname;
        pcd_col2res(nCol) = iR;
        
        % error check
        if ~isempty(ResultsSummary{iR})
            if ~(strcmp(ResultsHeader{nResults}{1},'FILE') || strcmp(ResultsHeader{nResults}{1},'CELL'))
                error('First column of accumulated data file should be FILE (m%dc%dr%d)');
            end
        end
    end
    
end
% check that variables are already loaded.
bVariableLoaded = 1;
% compute number of columns accumulated up to the previous column
nColumnsAccumulated = nPreDefinedColumns + [0 cumsum(nColumnsLoaded(1:end-1))];

% % create population data array and fill it with NaN
% for iMonk = 1:length(MonkOfInterest)
%     cPD{iMonk} = NaN(length(CellOfInterest{iMonk}), nCol);
%     cPD{iMonk}(:,1) = MonkOfInterest(iMonk);
%     cPD{iMonk}(:,2) = CellOfInterest{iMonk}(:);
% end

% create one row stuffed with NaN to avoid error in searching keys. will be
% deleted later.
aPD = NaN(1, nCol);
%% load population data
for iR=1:nResults
    if isempty(ResultsSummary{iR})
        error('ResultsSummary is empty');
    end    
    % seperated multiple data files. load files from directory
    if iscell(ResultsSummary{iR}) && isdir(ResultsSummary{iR}{1}) 
        error('not supported yet');
        for iM=1:length(MonkOfInterest)
            flist = dir([ResultsSummary{iR}{iM} '*.' ResultsExt{iR}]);
            for iF=1:length(flist)
                % extract monkey id, cell id, run id
                tmp = sscanf(flist(iF).name, 'm%dc%dr%d');
                monkid = tmp(1); cellid = tmp(2); runid = tmp(3);
                % check if data is of my interest
                iMonkNo = find(monkid == MonkOfInterest);
                if isempty(iMonkNo), continue; end
                iCellNo = find(cellid == CellOfInterest{iMonkNo});
                if isempty(iCellNo), continue; end
                % load one cell data
                fprintf(1, 'load %s\n', flist(iF).name);
                one_data = dlmread([ResultsSummary{iR}{iM} flist(iF).name]);
                % number of data columns in header and file should be same.
                if size(one_data,2) ~= length(bColumnsLoaded{iR})
                    error('size of header for ext(%s;%d) and data from file (%s;%d) do not match', ...
                        ResultsExt{iR}, length(bColumnsLoaded{iR}), flist(iF).name, size(one_data,2));
                end
                % of there is already a data, then overwrite it
                if any( ~isnan(cPD{iMonkNo}(iCellNo,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) )
                    fprintf(1,'Data already exist in {%d}(%d, %d-%d). Overwrite it', ...
                        iMonkNo, iCellNo, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                end
                % assign cell data to population data array
                cPD{iMonkNo}(iCellNo,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = one_data(:, iColumnsLoaded{iR});
            end
        end
    % accumulated data file for each subject
    elseif iscell(ResultsSummary{iR})
%         for iM=1:length(MonkOfInterest)
%             fprintf(1, 'load %s\n', ResultsSummary{iR}{iM});
%             all_columns_data = ReadCellDataByHeaders(ResultsSummary{iR}{iM}, ...
%                 MonkOfInterest, CellOfInterest, ResultsHeader{iR}, 1, ResultsMultipleDelims(iR)); 
%             cPD{iM}(:,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data{iM}(:,  iColumnsLoaded{iR}-1);
%         end
        for iM=1:length(MonkOfInterest)
            [all_columns_data nkey] = ReadCellDataKey(ResultsSummary{iR}{iM}, ResultsHeader{iR}, 1, ResultsMultipleDelims(iR));
            for iRow = 1:size(nkey,1)
                bSameNeuron = nkey(iRow,1) == aPD(:,MonkID) & nkey(iRow,2) == aPD(:,CellID) & ...
                    nkey(iRow,3) == aPD(:, ElectID) & nkey(iRow,4) == aPD(:, UnitID);
                if nnz(bSameNeuron) > 1, 
                    error('duplicate neuron key: %s', sprintf('%d ', nkey)); 
                end;

                if any(bSameNeuron)
                    % found the neuron key in the data. check there is already
                    % from same datafile
                    if any( ~isnan(aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) )
                        warning('Data already exist in %s {m%dc%de%du%d}(%d, %d-%d). Overwrite it', ...
                            ResultsSummary{iR}{iM}, nkey(iRow,1),nkey(iRow,2),nkey(iRow,3),nkey(iRow,4), iRow, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                    end
                    % update data.
                    aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-1);
                else % new neuron key. inser a raw
                    onerow = NaN(1, nCol);
                    onerow([1 2 3 4]) = nkey(iRow,[1 2 3 4]);
                    % why doing -1?
                    onerow(nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-1);
                    aPD(end+1,:) = onerow;

                end
            end
        end
    % accumulated single data file
    elseif isstr(ResultsSummary{iR})    
        %error('not supported yet');
        % celldata is a cell arrary.
        fprintf(1, 'load %s\n', ResultsSummary{iR});
        
        % same as above
        [all_columns_data nkey] = ReadCellDataKey(ResultsSummary{iR}, ResultsHeader{iR}, 1, ResultsMultipleDelims(iR));
            for iRow = 1:size(nkey,1)
                bSameNeuron = nkey(iRow,1) == aPD(:,MonkID) & nkey(iRow,2) == aPD(:,CellID) & ...
                    nkey(iRow,3) == aPD(:, ElectID) & nkey(iRow,4) == aPD(:, UnitID);
                if nnz(bSameNeuron) > 1, 
                    error('duplicate neuron key: %s', sprintf('%d ', nkey)); 
                end;

                if any(bSameNeuron)
                    % found the neuron key in the data. check there is already
                    % from same datafile
                    if any( ~isnan(aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) )
                        warning('Data already exist in %s {m%dc%de%du%d}(%d, %d-%d). Overwrite it', ...
                            ResultsSummary{iR}{iM}, nkey(iRow,1),nkey(iRow,2),nkey(iRow,3),nkey(iRow,4), iRow, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                    end
                    % update data.
                    aPD(bSameNeuron,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-1);
                else % new neuron key. inser a raw
                    onerow = NaN(1, nCol);
                    onerow([1 2 3 4]) = nkey(iRow,[1 2 3 4]);
                    % why doing -1?
                    onerow(nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data(iRow, iColumnsLoaded{iR}-1);
                    aPD(end+1,:) = onerow;

                end
            end
            
    end
end

% delete fist NaN raws
aPD(1,:) = [];

% sort by monk, cell, electrode and unit
[tmp iSortRow] = sortrows(aPD(:,[MonkID CellID ElectID UnitID]));
aPD = aPD(iSortRow,:);

% generate array type population data from cell type population data
%aPD = cat(1,cPD{:});
fprintf(1, 'Data loading completed!\n');