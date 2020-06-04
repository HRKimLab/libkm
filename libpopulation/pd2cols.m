function [mids cols] = pd2cols(v, bV1, bV2)
% separte single column in aPD using two row masks 
% 2018 HRK
aPD = evalin('base','aPD');
assert(size(aPD,1) == size(v, 1), 'aPD and v should have the same # of rows');
nRow = size(v,1);
% mice that learn VR task fast also learn bar moving fast
mids = unique(aPD(:,1));
cols = NaN(length(mids),2); 
for iM = 1:length(mids)
   mid =  mids(iM);
   bbV1 = aPD(:,1) == mid &  bV1;
   bbV2 = aPD(:,1) == mid &  bV2;
   
   if nnz(bbV1) == 1
        cols(iM,1) = v(bbV1);
   elseif nnz(bbV1) > 1
       warning('# of v matching the condition: %d', nnz(bbV1));
   end
   if nnz(bbV2) == 1
       cols(iM, 2) = v(bbV2);
   elseif nnz(bbV2) > 1
       warning('# of v matching the condition: %d', nnz(bbV2));
   end
   end