% A script showing the population analysis framework using libkm
% This script consists of two parts.
% In the first part, it load and combines analysis results across subjects
% In the second part, it shows some examples of population analyses
%
% 2020 HRK

% ANALYSIS_ROOT  = 'C:\D\data\DemoAnalysisRoot\'; % for HyungGoo
ANALYSIS_ROOT  = pwd;

% set cell numbers of interest for each monkey
MonkOfInterest = [159	209	210	211	213	214	215	217	218	219]; % 248 is missing
CellOfInterest = {1:100, 1:100, 1:100, 1:100, 1:100, 1:100, 1:100, 1:100, 1:100, 1:100, 1:100};
 
ResultsExt={}; ResultsHeader={};
nResults = 0; ResultsMultipleDelims=[];

nResults = nResults + 1;
ResultsExt{nResults} = 'ep2_';
ResultsHeader{nResults} = {'CELL', 'Date', 'sTime', 'Protocol', 'ParamMethod', 'VStimType', 'nTrial', 'nCorr', 'mDuration', 'mITI', ... % total
    'nStimCond', 'StimConds', 'nRew', 'nTarDist', 'nVisGain', 'mITIBreak', 'nITIBreak', 'FreeMoveDur'};
ResultsSummary{nResults} = 'exp_params.dat'
ResultsMultipleDelims(nResults) = 0;

nResults = nResults + 1;
ResultsExt{nResults} = 'beh_';
ResultsHeader{nResults} = 'CELL	durTILick	durITILick	impLick	antLick	postLick	impUnLick	antUnLick	postUnLick	elapsed_time	avgSpd_TI	maxSpd_TI	avgSpd_ITI	maxSpd_ITI	impSpd	antSpd	postSpd	impUnSpd	antUnSpd	postUnSpd';
ResultsSummary{nResults} = 'beh.dat'
ResultsMultipleDelims(nResults) = 0;

nResults = nResults + 1;
ResultsExt{nResults} = 'fr_';
ResultsHeader{nResults} = 'CELL	VStim	Cue500	CueOn_RewOn	Rew500	ITI	BefMoveOnTI	AftMoveOnTI	BefMoveOnITI	AftMoveOnITI	Cue2000	Rew2000	UnexpRew2000	BaseLine';
ResultsSummary{nResults} = 'fr_norm.dat'
ResultsMultipleDelims(nResults) = 0;

%% load data
% LoadPopulationDataKey;
% LoadPopulationData;
LoadPopulationData5Key;

% we can also load cell array of matlab file or text array. 
% This is commented out for now.
% %% load table data (tuning curves)
% nTC = 0; TCExt = {}; TCSummary = {}; TCColumnIntegrity=[]; TCMatInfo={};
% 
% nTC = nTC + 1;
% TCExt{nTC} = '.mat';
% % TCSummary{nTC} = {'Z:\HyungGoo\Analysis\27\trial_data\', 'Z:\HyungGoo\Analysis\32\trial_data\', 'Z:\HyungGoo\Analysis\36\trial_data\', 'Z:\HyungGoo\Analysis\37\trial_data\', 'Z:\HyungGoo\Analysis\38\trial_data\'};
% TCSummary{nTC} = 'trial_data\';
% TCColumnIntegrity(nTC) = 0;
% TCMatInfo{nTC} = 'one_time_params';
% 
% nTC = nTC + 1;
% TCExt{nTC} = '.mat';
% TCSummary{nTC} = 'trial_data\';
% TCColumnIntegrity(nTC) = 0;
% TCMatInfo{nTC} = 'trial_data';
% 
% % nTC = nTC + 1;
% % TCExt{nTC} = '.mat';
% % TCSummary{nTC} = 'trial_data\';
% % TCColumnIntegrity(nTC) = 0;
% % TCMatInfo{nTC} = 'neuron_data';
% % 
% % LoadTuningCurves;
% LoadTuningCurvesKey;
% % transfer mNeuronData elements to individual rows
% DistributeNeuronMap;
% % generate superset of aPD and TCunitkey and match row orders
% MatchNeuronKey;

%% pre-filter aPD data
% remove rows if all data values are NaNs
bElim = all(isnan(aPD(:, 6:end)), 2);
aPD = aPD(~bElim,:);

%% set boolean flags for set operations
bALL = true(size(aPD,1),1);
bSomeSubjects = ismember(aPD(:,1), [241 243 244]);
bNeuron = aPD(:,4) == 0 & aPD(:,5) == 1;
%% load psths
MICE = MonkOfInterest;

% psths ab reward onset
lick_RewOn = load_psth_files('lick_ab_RewOn.mat', MICE, 'analysis_root', ANALYSIS_ROOT);
loc_RewOn = load_psth_files('loc_ab_RewOn.mat', MICE, 'analysis_root', ANALYSIS_ROOT);

%%
global gP
gP.orient = 0;
gP.show_label = 1;   % keep label in formatfig() 
gP.show_title = 0;   % keep title in formatfig()
gP.save = 0;         % save figure ?
gP.cmap = @autumn;

IND_PSTH = 0;   

%%
setfig(2,2, 'Examples of analyses on task variable and behaviors');
gna;
plot_bargrp(aPD(:, ep2_nTrial), aPD(:, 1));
xlabel('Animal #'); ylabel('# of trials');
gna;
plot_bargrp(aPD(:, ep2_mDuration)/1000, aPD(:, 1), 'show_mc', 0);
xlabel('Animal #'); ylabel('trial duration (s)');
gna;
sdata = pd2sessiondata([], aPD(:, 1:5), [aPD(:, beh_antLick)-aPD(:, beh_impLick)  aPD(:,[beh_postLick beh_impLick])]);
hPL = plotm_xsession(sdata(:, 1:13, :), 'individual_style', '.', 'ebtype', 'bar', 'varname', {'AntLick'});
xlabel('Days of training'); ylabel('Lick (licks/s)');
legend(hPL(:,1), 'Net anticipatory','Post-rew','Impulsive');

%%
setfig(2,2, 'Examples of analyses on neural responses');
gna;
plot_barpair( aPD(bNeuron, [fr_Cue2000	fr_Rew2000	fr_UnexpRew2000]) );
set(gca,'xticklabel',{'Trial start','Exp. rew','Unexp. rew'});
xlabel('Task events'); ylabel('DA (zscore)');

gna;
plotsqscatter(aPD(bNeuron, [fr_Rew2000	]), aPD(bNeuron, [fr_UnexpRew2000]) )   
xlabel('DA, Exp rew (z)');ylabel('DA, Unexp rew (z)');

%% plot population time courses
% lick_RewOn = lick_TS;
% loc_RewOn = loc_TS;
% ft_lick_RewOn = filter_psth_by_n(lick_RewOn,'n_grp', 1);
% ft_loc_RewOn = filter_psth_by_n(loc_RewOn,'n_grp', 1);
ft_lick_RewOn = filter_psth_group(lick_RewOn,'argmax_gnumel');
ft_loc_RewOn = filter_psth_group(loc_RewOn,'argmax_gnumel');

setfig(1,2, 'Examples of analyses on time courses');
gna;
plot_mpsths(ft_lick_RewOn , 'event_header', 'RewOn','adjust_x_anyway', 1, 'x', [-8 4]);
xlabel('Time from reward (s)'); ylabel('Lick (lick/s)');
gna;
plot_mpsths(ft_loc_RewOn , 'event_header', 'RewOn', 'individual_psths', 1,'adjust_x_anyway',1, 'x', [-8 4]);
xlabel('Time from reward (s)'); ylabel('Running speed (cm/s)');
%% for each mouse or session
ft_lick_RewOn = filter_psth(ft_lick_RewOn, fullfact_vararg(NaN, 1:11, NaN, NaN, NaN));
ft_loc_RewOn = filter_psth(ft_loc_RewOn, fullfact_vararg(NaN, 1:11, NaN, NaN, NaN));
plot_mpsths_foreach(ft_lick_RewOn, 'subject', 'individual_psths', 1, 'adjust_x_anyway', 1, 'x', [-8 4]);
plot_mpsths_foreach(ft_lick_RewOn, 'session', 'adjust_x_anyway', 1, 'x', [-8 4]);