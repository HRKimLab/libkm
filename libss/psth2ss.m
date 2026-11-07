function [ss_rsp rspTCN cF] = psth2ss(psths)
% PSTH2SS convert psths structs to data structure for state-space plot (nTime * nNeuron).
%  [ss_rsp rspTCN cF] = psth2ss(psths) psths contains structs returned from plot_timecourse.
% 
% RETURN VALUES: 
%   Note that ss_rsp and rspTCN may contain NaNs.
%   ss_rsp: [(time*condition) x neuron] 
%   rspTCN: [time x condition x neuron]
%   cF    : cell array of the unitkeys
%
% TODO: I need to make another psth2ss for plot_timecourseMD
% 
% See also ss2TCN, TCN2ss, plot_timecourse
%
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
   % assign the serialized response to state space response
   ss_rsp(:, iF) = serialized_rsp;
   % also, assign it to TCN response
   rspTCN(:, :, iF) = avg_rsp';
end


% double check ssTCN and TCN2ss functions (it's also for checking the
% functions themselves since they are relatively new)
% transform from ss to (nTime * nCond * nNeuron)
assert( all(all(all( rspTCN == ss2TCN(ss_rsp, [nTime nCond nNeuron])  ))), ...
    'TCN conversion seems not right');
% transform from (nCond * nTime * nNeuron) to ss
assert(all(all( ss_rsp == TCN2ss(rspTCN) )), 'ss conversion seems not right');

% now, apply post-processing 