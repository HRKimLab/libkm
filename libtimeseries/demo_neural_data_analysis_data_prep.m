%% A section for data preparation. please ignore this part. 
% save it for libtimecourse tutorial
ms_time = data.motor_time;
lick = data.ts.Lick;
speed = data.motor_train(data.mch.DAQ_SPD,:);
position = data.motor_train(data.mch.POSY,:);
DAsensor = data.fp_train(1,:);
tbEvent = array2table(data.event_table, 'VariableNames', event_names);
event = tbEvent(:,{'TRIAL_START_CD','VSTIM_ON_CD','VSTIM_OFF_CD', 'REWARD_CD', 'TRIAL_END_CD'});
expcond = data.ginfo.grp;
save('Z:\km\public\libtimeseries\sample_session.mat', 'ms_time', 'lick','speed','DAsensor','expcond','event','position');

pop_psth = rmfield(ft_neuron, {'m81s20r1e0u1', 'm143s11r1e0u1', 'm140s10r1e0u1', 'm108s8r1e0u1', 'm112s5r2e0u1', 'm139s11r1e0u1','m137s16r1e0u1'} )
save('sample_pop_psth.mat', '-struct', 'pop_psth');