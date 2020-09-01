% transfer behavior results to neurons
% identify behavior results
% bBeh and KEY_COLS is required
% HRK 2018
assert(is_arg('bBeh') && is_arg('KEY_COLS'), 'bBeh (flag for behavior) and KEY_COLS (1:5)');
bBehRes = any(aPD(bBeh,:), 1); bBehRes(KEY_COLS) = false;

% iterate behavior rows
for iB = find(bBeh)'
   [bMember] = ismember(aPD(:, 1:3), aPD(iB, 1:3), 'rows');
   if nnz(bMember) > 0
        fprintf('transfer m%ds%dr%d behavior results to %d neurons\n', aPD(iB,1), aPD(iB,2), aPD(iB,3), nnz(bMember) );
   end
   for iN = find(bMember')
       % identical row. skip.
       if iB == iN, continue; end
       % neuron row. behavior column should be NaN
%        assert( all( isnan(aPD(iN, bBehRes)) ) );
       aPD(iN, bBehRes) = aPD(iB, bBehRes);
   end
end
