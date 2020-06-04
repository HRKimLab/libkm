% distribute cTC mNeuronData map structure to individual neuron key
% 8/5/2016 HRK
nTCCol = size(cTC, 2);

for iC = 1:size(cTC, 2)
    for iR = 1:size(cTC, 1)
        if ~strcmp(class(cTC{iR, iC}), 'containers.Map')
            continue;
        end
        
        d = cTC{iR, iC};
        k = keys(d);
        
        for iK = 1:length(k) 
            % extract unitkey
            [nkey] = ExtractUnitInfo(k{iK});
            % find if nkey exists in TCunitkey
            if isempty(TCunitkey), bSameNeuron = false;
            else
                bSameNeuron = nkey(:,1) == TCunitkey(:,1) & nkey(:,2) == TCunitkey(:,2) & ...
                    nkey(:,3) == TCunitkey(:,3) & nkey(:,4) == TCunitkey(:,4);
                assert(nnz(bSameNeuron) < 2, 'redundant unit keys are found');
            end
            
            if any(bSameNeuron)
                iRow = find(bSameNeuron);
                error('Same neuron %s [%s] found in %d', k{iK}, sprintf('%d ', nkey), iRow);
            else % new unitkey
                iRow = size(TCunitkey,1) + 1;
                TCunitkey = [TCunitkey; nkey];
            end
            % assign
            cTC(iRow, 1:(nTCCol-1)) = cTC(iR, 1:(nTCCol-1));
            cTC{iRow, nTCCol+1} = d( k{iK} );
        end
    end
end

fprintf(1, 'Distributing neuronal data map completed!\n');

% sort results according to unitkey
[tmp iSortRow] = sortrows(TCunitkey);
TCunitkey = TCunitkey(iSortRow,:);
cTC = cTC(iSortRow,:);