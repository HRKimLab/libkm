% test script for inc_update_TNC and append_TN 

global gPopRsp


nTime = 1000;	% 1s (1000ms)
nNeuron = 30;
nCond = 8;

% e.g., stimulus onset is 0.2s from start
s_time = ((1:nTime)/1000 - 0.2)';
% s_time = repmat(((1:nTime)/1000 - 0.2)', [1 nNeuron]);
gid_list = repmat(randsample(nCond, nCond), [1000,1]);


setfig(1, nCond, 'test append_TN');
ax=[];
for iC=1:nCond
	ax(iC)=gna;
end

for iTrial = 1:20
	TN = rand(nTime, nNeuron);
	gid = gid_list(iTrial);
	if iTrial == 1 % initialize global variable
		init_ngrp = nCond;
	else
		init_ngrp = 0;
	end
	
	% incrementally update mean and variance
	inc_update_TNC(TN, gid, init_ngrp);
	% append 
	append_TN(TN, gid, init_ngrp);
	
	% plot activities
	for iC = 1:nCond
% 		plot(ax(iC), s_time, gPopRsp.TNC(:,:,iC) );
		plot(ax(iC), s_time, zscore( gPopRsp.TNC(:,:,iC), [], 1) );
	end
	drawnow;
	
	% skip if not all gids are repeated twice (for computing variance)
	if iTrial <= nCond * 2
		continue;
	end
	
	assert( all(all(all(abs( gPopRsp.TNC - TNTr2TNC(gPopRsp.TNTr(:,:,1:gPopRsp.trial_index), gPopRsp.gids(1:gPopRsp.trial_index), ...
		'func', @nanmean, 'n_cond', nCond) ) < 0.000001))));
	assert( iTrial == 1 || all(all(all(abs(gPopRsp.Var_sample - TNTr2TNC(gPopRsp.TNTr(:,:,1:gPopRsp.trial_index), gPopRsp.gids(1:gPopRsp.trial_index), ...
		'func', @nanvar, 'n_cond', nCond)) < 0.00001))));
end

% manually check the last results
gPopRsp.TNC - TNTr2TNC(gPopRsp.TNTr(:,:,1:gPopRsp.trial_index), gPopRsp.gids(1:gPopRsp.trial_index), ...
		'func', @nanmean, 'n_cond', nCond)
gPopRsp.Var_sample - TNTr2TNC(gPopRsp.TNTr(:,:,1:gPopRsp.trial_index), gPopRsp.gids(1:gPopRsp.trial_index), ...
		'func', @nanvar, 'n_cond', nCond)