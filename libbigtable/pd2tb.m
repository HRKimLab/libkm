function tb_val = pd2tb(keys, v, tD, ROW_OFF, COL_OFF)
% map a pd column onto tb cell array of neuronname
% the size of output array (tb_val) is same as that of input cell array (tb),
% including ROW_OFF, COL_OFF.
% 2019 HRK
% v: pd colum of interest
% tb: cell array (table) contains unitname

assert(size(keys, 1) == size(v, 1) );

if ~is_arg('ROW_OFF'), ROW_OFF = 2; end
if ~is_arg('COL_OFF'), COL_OFF = 2; end

if istable(tD)
    tb = table2cell(tD); 
elseif iscell(tD)
    tb = tD;
else, error('tD should be either table or cell array');
end

tb_val = NaN(size(tb));
% iterate table
for iC = COL_OFF:size(tb, 2)
    for iR = ROW_OFF:size(tb, 1)
        if isempty( tb{iR, iC} ) || tb{iR, iC}(1) == '%' || tb{iR, iC}(1) == '-'
            continue;
        end
        nk = str2unitkey5(tb{iR, iC});
        bMatch = all( abs(bsxfun(@minus, keys, nk)) < 0.00001, 2);
        if nnz(bMatch) == 1
            tb_val(iR, iC) = v(bMatch);
        elseif nnz(bMatch) == 0
            warning('Cannot find key %s in aPD', tb{iR, iC});
        elseif nnz(bMatch) > 1
            warning('Multiple elements find match %s', tb{iR, iC});
            keys(bMatch,:)
        end
    end
end

if istable(tD)
    tb_val = array2table(tb_val, 'VariableNames', tD.Properties.VariableNames);
end