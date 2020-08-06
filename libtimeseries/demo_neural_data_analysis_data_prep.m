% script to store data for libtimeseries demo script
% 2018 HRK
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

%%
ft_lick = filter_psth( lick_LocOnV, get_datanames(tD, 'VR_SPD2') );
ft_lick = rmfield(ft_lick, {'m81s20r1', 'm143s11r1', 'm140s10r1', 'm108s8r1', 'm112s5r2', 'm139s11r1','m137s16r1'} )
save('lick_TrialOn.mat', '-struct', 'ft_lick');

ft_loc = filter_psth( loc_LocOnV, get_datanames(tD, 'VR_SPD2') );
ft_loc = rmfield(ft_loc, {'m81s20r1', 'm143s11r1', 'm140s10r1', 'm108s8r1', 'm112s5r2', 'm139s11r1','m137s16r1'} )
save('loc_TrialOn.mat', '-struct', 'ft_loc');

ft_neuron = filter_psth(neuron_LocOnV, get_datanames(tD, 'VR_SPD2') );
ft_neuron = rmfield(ft_neuron , {'m81s20r1e0u1', 'm143s11r1e0u1', 'm140s10r1e0u1', 'm108s8r1e0u1', 'm112s5r2e0u1', 'm139s11r1e0u1','m137s16r1e0u1'} )
save('GCaMP_TrialOn.mat', '-struct', 'ft_neuron');
