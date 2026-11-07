global data

%% using data.pop
[a b c] = psth2ss( data.pop.pop_psths );


%% using plot_timecourseMD

[~, psth] = plot_timecourseMD('stream', data.inst_fr', data.event_table(:, VSTIM_ON_CD), 0, 8000, data.ginfo,'psth_type','none');
%%
b_nr = data.pop.nr_stats.m_fr > 5;
analyze_state_space(psth.mean(:,:,b_nr));