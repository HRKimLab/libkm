%% load data
% recognize valid columns, create variables for convenient column indexing 
% using [fileext column] naming convention. 
nCol = 0; bColumnsLoaded = {}; iColumnsLoaded = {}; nColumnsLoaded=[];
pcd_colname = {}; pcd_col2res=[]; cPD={}; aPD=[];

% first two columns are monkey id, cell id
nCol = nCol + 1;
cmd_str = ['MonkID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{1} = 'MonkID';
nCol = nCol + 1;
cmd_str = ['CellID' ' = ' num2str(nCol) ';'];
eval(cmd_str);
pcd_colname{2} = 'CellID';

% iterate result formats
for iR=1:nResults
    % load columnes except defineds as 'NA' (not available)
    bColumnsLoaded{iR} = cellfun(@(x) ~(strcmp(x, 'NA') | strcmp(x,'FILE') | strcmp(x, 'CELL')), ResultsHeader{iR});
    iColumnsLoaded{iR} = find(bColumnsLoaded{iR});
    nColumnsLoaded(iR) = sum(bColumnsLoaded{iR});
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
nColumnsAccumulated = 2 + [0 cumsum(nColumnsLoaded(1:end-1))];

% create population data array and fill it with NaN
for iMonk = 1:length(MonkOfInterest)
    cPD{iMonk} = NaN(length(CellOfInterest{iMonk}), nCol);
    cPD{iMonk}(:,1) = MonkOfInterest(iMonk);
    cPD{iMonk}(:,2) = CellOfInterest{iMonk}(:);
end

%% load population data
for iR=1:nResults
    if isempty(ResultsSummary{iR})
        error('ResultsSummary is empty');
    end    
    % seperated multiple data files. load files from directory
    if iscell(ResultsSummary{iR}) && isdir(ResultsSummary{iR}{1}) 
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
                if any( ~isnan(cPD{iMonkNo}(iCellNo,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) ) && ...
                    any(cPD{iMonkNo}(iCellNo,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) ~= one_data(:, iColumnsLoaded{iR}))
                    warning('New data in {%d}(%d, %d-%d) will overwrite old data', ...
                        iMonkNo, iCellNo, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                elseif any( ~isnan(cPD{iMonkNo}(iCellNo,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR)))) )
                    warning(' Redundant Data {%d}(%d, %d-%d) already exist', ...
                        iMonkNo, iCellNo, nColumnsAccumulated(iR)+1, nColumnsAccumulated(iR)+ nColumnsLoaded(iR));
                end
                % assign cell data to population data array
                cPD{iMonkNo}(iCellNo,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = one_data(:, iColumnsLoaded{iR});
            end
        end
    % accumulated data file for each subject
    elseif iscell(ResultsSummary{iR})     
        for iM=1:length(MonkOfInterest)
            fprintf(1, 'load %s\n', ResultsSummary{iR}{iM});
            all_columns_data = ReadCellDataByHeaders(ResultsSummary{iR}{iM}, ...
                MonkOfInterest, CellOfInterest, ResultsHeader{iR}, 1, ResultsMultipleDelims(iR)); 
            cPD{iM}(:,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data{iM}(:,  iColumnsLoaded{iR}-1);
        end
    % accumulated single data file
    elseif isstr(ResultsSummary{iR})    
        % celldata is a cell arrary.
        fprintf(1, 'load %s\n', ResultsSummary{iR});
        all_columns_data = ReadCellDataByHeaders(ResultsSummary{iR}, ...
            MonkOfInterest, CellOfInterest, ResultsHeader{iR}, 1, ResultsMultipleDelims(iR));
        % iterate each monkey
        for iM=1:length(MonkOfInterest)
            % take valid columns, and assign values to cPD. shift column
            % index leftward to exclude FILE
            cPD{iM}(:,nColumnsAccumulated(iR)+(1:nColumnsLoaded(iR))) = all_columns_data{iM}(:,  iColumnsLoaded{iR}-1);
        end
    end
end

% generate array type population data from cell type population data
aPD = cat(1,cPD{:});
fprintf(1, 'Data loading completed!\n');