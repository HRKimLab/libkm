% union neuron keys aPD and TCunitkey
union_key = union(aPD(:, 1:4), TCunitkey, 'rows');
new_aPD = NaN(size(union_key,1), size(aPD, 2) );
new_cTC = cell(size(union_key,1), size(cTC, 2) );
new_bPDBehavior = NaN(size(union_key,1), 1);
new_bPDNeuron = NaN(size(union_key,1), 1);

% iterate the superkey key array
for iR = 1:size(union_key, 1)
    iMatch_aPD = find( union_key(iR, 1) == aPD(:, 1) & union_key(iR, 2) == aPD(:, 2) & union_key(iR, 3) == aPD(:, 3) & union_key(iR, 4) == aPD(:, 4));
    switch(length(iMatch_aPD))
        case 0
        case 1
              new_aPD(iR,:) = aPD(iMatch_aPD, :);
        otherwise
            error('Multiple match key: %s', num2str(union_key(iR, 1:4)) );
    end
    
    
    iMatch_cTC = find( union_key(iR, 1) == TCunitkey(:, 1) & union_key(iR, 2) == TCunitkey(:, 2) & union_key(iR, 3) == TCunitkey(:, 3) & union_key(iR, 4) == TCunitkey(:, 4));
    switch(length(iMatch_cTC))
        case 0
        case 1
              new_cTC(iR,:) = cTC(iMatch_cTC, :);  
        otherwise
            error('Multiple match key: %s', num2str(union_key(iR, 1:4)) );
    end

    assert( ~isempty(iMatch_aPD) || ~isempty(iMatch_cTC) );
end

assert( all(all(new_aPD(~isnan(new_aPD(:, 1)), 1:4) == union_key(~isnan(new_aPD(:, 1)), 1:4))) );
new_aPD(:, 1:4) = union_key(:, 1:4);
TCunitkey = union_key;

aPD = new_aPD;
cTC = new_cTC;
bPDBehavior = aPD(:,3) == -1 & aPD(:,4) == -1;
bPDNeuron = ~bPDBehavior;

clear new_aPD new_cTC