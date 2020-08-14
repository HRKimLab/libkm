% Load variable-size data into cell array
% input: MonkOfInterest, CellOfInterest
%        TCExt, TCSummary, TCMatInfo
% output: cTC_M(iMonk},{iCell, iResult}, cTC
% 6/13/2013 HRK

cTC_M = {}; cTC={};

nCol=0;
% generate column variables
for iTC=1:nTC
    % load columnes except defineds as 'NA' (not available)
        nCol = nCol + 1;
        varname = TCExt{iTC};
        % add suffix 'TC'
        cmd_str = ['TC' varname ' = ' num2str(nCol) ';'];
        % check variable name redundancy, if loaded for the first time
        if ~exist('bTCVariableLoaded','var') && exist(varname,'var')
            error('TC variable name %s is redundant', varname);
        end
            
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
%                 fname = sprintf('m%dc%dr*.%s', monkid , cellid, TCExt{iR});
                fname = sprintf('m%ds%dr*.%s', monkid , cellid, TCExt{iR});
            else % otherwise, it is concatenated following the filename (e.g., '_rm.mat')
%                 fname = sprintf('m%dc%dr*%s', monkid , cellid, TCExt{iR});
                fname = sprintf('m%ds%dr*%s', monkid , cellid, TCExt{iR});
            end
                
            % set search directory
            if iscell(TCSummary{iR})
                tuning_dir = TCSummary{iR}{iM};
            elseif isstr(TCSummary{iR}) && isdir(TCSummary{iR})
                tuning_dir = TCSummary{iR};
            elseif isstr(TCSummary{iR}) && ~isdir(TCSummary{iR})
                tuning_dir = [ANALYSIS_ROOT filesep num2str(MonkOfInterest(iM)) filesep TCSummary{iR}];
            else
                tuning_dir = [ANALYSIS_DIR{MonkOfInterest(iM)} TCSummary{iR}];
            end
            % file files
            flist = dir([tuning_dir fname]);
            if isempty(flist), cTC_M{iM}{iC, iR} = []; continue; end;
            % for debug. print filename to be loaded
            fprintf(1, '[%s]  ', flist(1).name);
            % if multiple files exist, allow overwrite
            for iF=1:length(flist)
                if length(flist) > 1
                    [pathstr, fname1, ext1] = fileparts(flist(iF).name);
                    fprintf('[[%s]] ', fname1)
                end
                % check if matlab file
                if is_arg('TCMatInfo') && length(TCMatInfo) >= iR && ~isempty(TCMatInfo{iR}) 
                    if iscell(TCMatInfo{iR})    % multiple variables in .mat file
                        
                    elseif isstr(TCMatInfo{iR}) % single variable in .mat file
                        tmp = load('-mat', [tuning_dir flist(1).name], TCMatInfo{iR});
                        if ~isfield(tmp, (TCMatInfo{iR}))
                            warning('cannot find variable %s in file %s', TCMatInfo{iR}, [tuning_dir flist(1).name]);
                            cTC_M{iM}{iC, iR} = [];
                        else
                            cTC_M{iM}{iC, iR} = tmp.(TCMatInfo{iR});
                        end
                    else % some other .mat file loading methods
                    end
                else % text file
                    [tmp1 tmp2 isHeader]=ReadDataFileHeader([tuning_dir flist(1).name], TCColumnIntegrity(iR));

                    try % TODO: should fix this
                        cTC_M{iM}{iC, iR} = dlmread([tuning_dir flist(1).name], '\t', isHeader, 0);
                    catch
                        cTC_M{iM}{iC, iR} = dlmread([tuning_dir flist(1).name], ',', isHeader, 0);
                    end
                end
            end
            if length(flist) > 1, fprintf(1, '\n'); end;
        end
    end
end

fprintf(1, 'Loading tuning curves completed!\n');

% it is not really array, but just do this for now.
cTC = cat(1,cTC_M{:});