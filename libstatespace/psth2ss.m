function [ss_rsp rspTCN cF] = psth2ss(psths)
% convert psths struct to state-space (nTime * nNeuron)
% 2022 HRK
ss_rsp = [];
rspTCN = [];

cF = fieldnames(psths);
% nF: number of neurons
nNeuron = numel(cF);
nCond = size(psths.(cF{1}).mean, 1);
nTime = size(psths.(cF{1}).mean, 2);

for iF = 1:numel(cF)
   psth = psths.(cF{iF});
   % take mean responses (nCond * nTime)
   avg_rsp = psth.mean;
   % there should be no NaNs
   assert(all(all(~isnan(avg_rsp))), 'psth.mean of %s contains NaN', cF{iF});
   % attach NaN at the end
%    avg_rsp = [avg_rsp NaN(size(avg_rsp, 1), 1)];
   avg_rsp = [avg_rsp];
   
   % fix weird responses. Otherwise PCA is dominated by these values.
   bOutlier = avg_rsp > 150;
   if nnz(bOutlier(:))
       fprintf(1, 'adjust following responses to 150 (%s)\n', cF{iF});
       tmp = avg_rsp(bOutlier);
       tmp(:)
       avg_rsp(bOutlier) = 150;
   end
   % serizlied_rsp is (nTime * nCond)
   serialized_rsp = avg_rsp';
   % now vetorize it
   serialized_rsp = serialized_rsp(:);
   % assign it to state space resposne
   ss_rsp(:, iF) = serialized_rsp;
   rspTCN(:, :, iF) = avg_rsp';
end

%ss2TCN(rspTCN, [nTime nCond nNeuron])
% TCN2ss(ss_rsp)
% transform from ss to (nTime * nCond * nNeuron)
all(all(all( rspTCN == ss2TCN(ss_rsp, [nTime nCond nNeuron])  )))
% transform from (nCond*nTime*nNeuron) to ss
all(all( ss_rsp == TCN2ss(rspTCN) ))
