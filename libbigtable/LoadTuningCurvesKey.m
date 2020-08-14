% Load variable-size data into cell array
% input: MonkOfInterest, CellOfInterest
%        TCExt, TCSummary, TCMatInfo
% output: cTC_M(iMonk},{iCell, iResult}, cTC
% 6/13/2013 HRK

cTC_M = {}; cTC={}; TCunitkey = [];

nCol=0;
% generate column variables
for iTC=1:nTC
    % load columnes except defineds as 'NA' (not available)
        nCol = nCol + 1;
        varname = TCExt{iTC};
        % if load from TCMatInfo{nTC}, append varible name
        if ~isempty(TCMatInfo{iTC}) && length(TCMatInfo{iTC}) > 0
           varname = [regexprep(TCExt{iTC},'.mat','','ignorecase') '_' TCMatInfo{iTC}];
        end
        % add suffix 'TC'
        cmd_str = ['TC' varname ' = ' num2str(nCol) ';'];
        % check variable name redundancy, if loaded for the first time
        if ~exist('bTCVariableLoaded','var') && exist(varname,'var')
            error('TC variable name %s is redundant', varname);
        end
            
        cmd_str = regexprep(cmd_str, '*', '');
        eval(cmd_str);   
end
bTCVariableLoaded = 1;

for iR = 1:length(TCExt)
    fprintf(1, 'Loading %s\n', TCExt{iR});
    % iterate monkeys and cells
    for iM=1:length(MonkOfInterest)
        for iC=1:length(CellOfInterest{iM})
            % get monkey id, cell id
            monkid = MonkOfInterest(iM);
            cellid = CellOfInterest{iM}(iC);
            % make filename. if ext doesn't include '.', it's an extension.
            if isempty(findstr(TCExt{iR}, '.'))
                fname = sprintf('m%ds%dr*.%s', monkid , cellid, TCExt{iR});
            else % otherwise, it is concatenated following the filename (e.g., '_rm.mat')
                fname = sprintf('m%ds%dr*%s', monkid , cellid, TCExt{iR});
            end
            
            % set search directory
            if iscell(TCSummary{iR})
                tuning_dir = TCSummary{iR}{iM};
            elseif isstr(TCSummary{iR}) && isdir(TCSummary{iR})
                tuning_dir = TCSummary{iR};
            else
                tuning_dir = [ANALYSIS_ROOT num2str(MonkOfInterest(iM)) filesep TCSummary{iR}];
            end
            % file files
            flist = dir([tuning_dir fname]);
            if isempty(flist)
                % cTC{iRow, iR} = []; I should not this in Key-based
                % loading. it will overwrite previous entry.. HRK 7/9/2014 
                continue; 
            end;
            % for debug. print filename to be loaded
            fprintf(1, '[%s]  ', flist(1).name);
            % if multiple files exist, allow overwrite
            for iF=1:length(flist)
                if length(flist) > 1
                    [pathstr, fname1, ext1] = fileparts(flist(iF).name);
                    fprintf('[[%s]] ', fname1)
                end
                
                % extract unitkey
                [nkey] = ExtractUnitInfo(flist(iF).name);
                if nkey(3) ~= -1 && nkey(4) ~= -1 % for now, disable loading _TT0_01.mat files
%                     disp('Loading neural data');
                else
                end
                % find if nkey exists in TCunitkey
                if isempty(TCunitkey), bSameNeuron = false;
                else
                    bSameNeuron = nkey(:,1) == TCunitkey(:,1) & nkey(:,2) == TCunitkey(:,2) & ...
                        nkey(:,3) == TCunitkey(:,3) & nkey(:,4) == TCunitkey(:,4);
                    assert(nnz(bSameNeuron) < 2, 'redundant unit keys are found');
                end

                if any(bSameNeuron)
                    iRow = find(bSameNeuron);
                else % new unitkey
                    iRow = size(TCunitkey,1) + 1;
                    TCunitkey = [TCunitkey; nkey];
                end

                % check if matlab file
                if is_arg('TCMatInfo') && length(TCMatInfo) >= iR && ~isempty(TCMatInfo{iR}) 
                    if iscell(TCMatInfo{iR})    % multiple variables in .mat file
                        
                    elseif isstr(TCMatInfo{iR}) % single variable in .mat file
                        tmp = load('-mat', [tuning_dir flist(iF).name], TCMatInfo{iR});
                        if isfield(tmp, TCMatInfo{iR})
                            cTC{iRow, iR} = tmp.(TCMatInfo{iR});
                        else
%                             warning('Cannot find variable %s in %s', TCMatInfo{iR}, [tuning_dir flist(1).name])
                        end
                     else % some other .mat file loading methods
                    end
                else % text file
                    [tmp1 tmp2 isHeader] = ReadDataFileHeader([tuning_dir flist(1).name], TCColumnIntegrity(iR));

                    try % TODO: should fix this
                        cTC{iRow, iR} = dlmread([tuning_dir flist(1).name], '\t', isHeader, 0);
                    catch
                        cTC{iRow, iR} = dlmread([tuning_dir flist(1).name], ',', isHeader, 0);
                    end
                end
            end
            if length(flist) > 1, fprintf(1, '\n'); end;
        end
    end
end

fprintf(1, 'Loading tuning curves completed!\n');

% sort results according to unitkey
[tmp iSortRow] = sortrows(TCunitkey);
TCunitkey = TCunitkey(iSortRow,:);
cTC = cTC(iSortRow,:);