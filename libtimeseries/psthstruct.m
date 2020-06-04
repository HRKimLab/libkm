function st = psthstruct(cPSTH, cName)

assert(all(size(cPSTH) == size(cName) ) );
st = struct();

for iR=1:size(cPSTH,1)
    for iC=1:size(cPSTH,2)
        if isempty(cPSTH{iR, iC})
            continue;
        end
        if isempty(cName{iR, iC})
            warning('no name for valid psth (%d, %d)', iR, iC);
        end
        
        
        st.(cName{iR,iC}) = cPSTH{iR,iC};
    end
end