% A demo of Matlab functions for exploratory population data analysis
% This demo consists of two part. The first partintroduces a number of
% plotting functions. What makes these functions useful is 1) they show 'N' 
% for data verification and ignores NaNs. 2) perform basic computation (e.g., 
% linear regression) and statistics (e.g., signed rank test) related to the plots.
% 3) additional options makes them strong and flexble. Open each
% function to see a list of available options.
% The second part shows how to load population data. The loading functions
% generate a gigantic 2D array of [entity * features], where entities are either
% neurons or subjects, and features are columns in the text file containing
% numeric data. The first column of text file should be dataname. The text file 
% is assumed to be saved with a specific folder structure. So you may need
% to work on changing folder structure if you want to use this framework.
% Once data is loaded in the gigantic 2D array form, it goes well with the 
% plotting functions in the first part.
% 
% see also DEMO_TIMECOURSE_DATA_ANALYSIS, DEMO_SAVE_SU_RESULTS 

% 3/15/2014 HRK.

%% first part.

% generate x, y, and group (e.g, animal id)
x = randn(100, 1); x_sig = abs(x)
y = x * 2 + randn(100,1);
z = x * 0.5 + rand(100,1);
grp = round(rand(100,1) * 3);

%% scatterplots and basic stats
setfig(2,3);
% plot x and y scatter 
gna; plot_scatter(x,y);
% plot x and y scatter with the same scale
gna; plotsqscatter(x,y);
% show groups
gna; plotsqscatter(x,y, grp,'marker_size', 3);
% use smaller range. # of outliers are shown
gna; plotsqscatter(x,y, grp, 'xl', [-2 2],'marker_size', 3);
% let's say on data point is NaN.
x(1) = NaN;
gna; plotsqscatter(x,y, grp,'marker_size', 3);
% use type 1 regression. check output arguments
gna; [r,p,N,sl,itc,fitdata,pSR, hS] = plotsqscatter(x,y, grp, 'regress_type', 'type1','marker_size', 3)

%% histograms
a = x + 1; b = y + 1; c = b + 2;

setfig(2,2);
% significance
gna; plot_histsig(a, abs(a)>2);
% groups
gna; plot_histgrp(a, grp, -3:.25:3, 0.5);

%% bar plots with basic stats
setfig(2,2);

[v g] = cols2grp(a, 1, b, 2, c, 3);
% unpaird bar plots
gna; plot_bargrp(v, g);
% paired bar plots
gna; plot_barpair([a b], [abs(a)>2 abs(b)>2.5]);
% show referenc line and stats
gna; plot_barpair([a b], [abs(a)>2 abs(b)>2.5], 0);
% parametric test
gna; plot_barpair([a b c], [abs(a)>2 abs(b)>2.5 abs(c)>2.5], 0, 'test_type','par');

%% second part.
PopAnalysisDefs;

% criterion for defining outlier 
% re-written using new data loading method
NTCrit = 500;
bSave2File = 0
% specify a directory with accumulated result files.
INTEG_ANALYSIS_DIR = 'Z:\LabTools\Matlab\TEMPO_Analysis\CommonTools\PopLib\AnalysisData\';
% This script will generate final data file for Origin into figure data directory.
FIG_DATA_DIR = 'Z:\LabTools\Matlab\TEMPO_Analysis\CommonTools\PopLib\FigData\';

MonkOfInterest = [32 31];
% set cell numbers of interest for each monkey
CellOfInterest = {[189 216 244 266 271:378], 24:220}; % 446:541}; % is abbott cell range correct?

ResultsExt={}; ResultsHeader={};
nResults = 0; ResultsMultipleDelims=[];

%%%%%%%%%%%
% load separate result files for each cell
% if ResultsSummary is directory, files with given range of mXXcXXrXX.zzz
% (zzz is ResultsExt)
%%%%%%%%%%%%
% DIRECTION_TUNING properties
nResults = nResults + 1;
ResultsExt{nResults} = 'dir';
ResultsHeader{nResults} = {'BaseRate','Amplitude','PREF_DIR','q4','Width_FWHM','MaxResp','SpontResp','DSI','CurveANOVA','MappedPrefDir','PrefSpeed','PrefHDisp','RFXCtr','RFYCtr','Diam'};
ResultsSummary{nResults} = TUNING_DIR(MonkOfInterest);
ResultsMultipleDelims(nResults) = 0;

% SPEED_TUNING properties
nResults = nResults + 1;
ResultsExt{nResults} = 'spd';
ResultsHeader{nResults} = {'MaxSpeed','MaxResp','MinSpeed','MinResp','AveResp','SpontResp','CurveANOVA','Fit_q1','Fit_q2','Fit_q3','Fit_q4','Fit_q5','PrefDir','PrefSpeed', 'MappedPrefHDisp','RFXCtr','RFYCtr','RFDiam'};
ResultsSummary{nResults} = TUNING_DIR(MonkOfInterest)
ResultsMultipleDelims(nResults) = 0;

% RF_MAPPING properties
nResults = nResults + 1;
ResultsExt{nResults} = 'rf_map';
ResultsHeader{nResults} = {'SpontRate',	'RFSizeScale', 'RFGridScale', 'Fit_BaseRate', 'Fit_Amplitude','Fit_XWidth','Fit_YWidth','Fit_XCtr','Fit_YCtr'};
ResultsSummary{nResults} = TUNING_DIR(MonkOfInterest)
ResultsMultipleDelims(nResults) = 0;

% HDISP_TUNING properties
nResults = nResults + 1;
ResultsExt{nResults} = 'hdsp';
ResultsHeader{nResults} = {'Speed',	'AveResp',	'SpontResp','MaxResp','HdispAtMax','MinResp','HdispAMin','CurveANOVA','DTI','DDI','CorrCoef','DispN16','DispN12','DispN08','DispN04','Disp0','DispP04','DispP08','DispP12','DispP16','LControl','RControl','UControl','PrefDir','PrefSpeed','MappedPrefHDisp','RFXCtr','RFYCtr','RFDiam'};
ResultsSummary{nResults} = TUNING_DIR(MonkOfInterest)
ResultsMultipleDelims(nResults) = 0;

%%%%%%%%%%%%%%%
% load data from accumulated result file
% ResultsSummary can be one single file or cell array of multiple files for each monkey.
%%%%%%%%%%%%%%%
% SIZE_TUNING properties
nResults = nResults + 1;
ResultsExt{nResults} = 'size';
ResultsHeader{nResults} = {'FILE','PrDir','PrSpd','PrHDsp','RFX','RFY','RFDiam','K','a','R0','Ke','ae','Ki','bi','R0a','OptSiz', 'PctSI','Fseq','Pseq','R2raw','Praw','R2mean','Pmean','Chi2E','ChiPE','Chi2DE','ChiPDE'};
ResultsSummary{nResults} = 'Z:\LabTools\Matlab\TEMPO_Analysis\ProtocolSpecific\SizeTuning\v3ASizeTuningSummary.dat';
ResultsMultipleDelims(nResults) = 1;

% electrode position information
nResults = nResults + 1;
ResultsExt{nResults} = 'elect';
ResultsHeader{nResults} = {'FILE','XPos','YPos','Depth'};
ResultsSummary{nResults} = 'Z:\Data\MOOG\Chunky\Analysis\electrode_position.dat';
ResultsMultipleDelims(nResults) = 0;

% RM DSDI mean properties
nResults = nResults + 1;
ResultsExt{nResults} = 'rm_mean';
ResultsHeader{nResults} = {'FILE','Condition','null','neg20','neg15','neg10','neg05','pos0','pos05','pos10','pos15','pos20', 'errnull','errneg20','errneg15','errneg10','errneg05','err0','err05','err10','err15','err20','PDI20','PDI15','PDI10','PDI05', 'mPDI','p','sigp'};
ResultsSummary{nResults} = {'Z:\Data\MOOG\Chunky\Analysis\DSDI\RM_means.txt', 'Z:\Data\MOOG\Abbott\Analysis\DSDI\RM_means.txt'};
ResultsMultipleDelims(nResults) = 0;

% MP DSDI mean properties
nResults = nResults + 1;
ResultsExt{nResults} = 'mp_mean';
ResultsHeader{nResults} = {'FILE','Condition','null','neg20','neg15','neg10','neg05','pos0','pos05','pos10','pos15','pos20', 'errnull','errneg20','errneg15','errneg10','errneg05','err0','err05','err10','err15','err20','PDI20','PDI15','PDI10','PDI05', 'mPDI','p','sigp'};
ResultsSummary{nResults} = {'Z:\Data\MOOG\Chunky\Analysis\DSDI\MP_means.txt', 'Z:\Data\MOOG\Abbott\Analysis\DSDI\deprecated\MT_MP_means_fullset.txt'};
ResultsMultipleDelims(nResults) = 0;

% read HDISP DSDI mean properties
nResults = nResults + 1;
ResultsExt{nResults} = 'hdsp_mean';
ResultsHeader{nResults} = {'FILE','Condition','null','neg20','neg15','neg10','neg05','pos0','pos05','pos10','pos15','pos20', 'errnull','errneg20','errneg15','errneg10','errneg05','err0','err05','err10','err15','err20','PDI20','PDI15','PDI10','PDI05', 'mPDI','p','sigp'};
ResultsSummary{nResults} = {'Z:\Data\MOOG\Chunky\Analysis\DSDI\HDISP_means.txt', 'Z:\Data\MOOG\Abbott\Analysis\DSDI\HDISP_means.txt'};
ResultsMultipleDelims(nResults) = 0;

% neuronal threshold by mean firing rate 
nResults = nResults + 1;
ResultsExt{nResults} = 'thr_mean';
ResultsHeader{nResults} = {'FILE','PrDir','PrSpd','PrHDsp','RFX','RFY','RFDiam','Nthr','NSlp','Mthr','MSlp','DspLo','DspHi','Ntrials','HCorr','ROChCorr','NovarMean','NovarVar','VarMeam','VarVar'};
%ResultsSummary{nResults} = 'NeuroPsycho_Curve_summary_SU_fr.dat';
ResultsSummary{nResults} = [INTEG_ANALYSIS_DIR 'NeuroPsycho_Curve_summary.dat'];
ResultsMultipleDelims(nResults) = 1;

% neuronal threshold by MI (modulation index)
nResults = nResults + 1;
ResultsExt{nResults} = 'thr_mi';
ResultsHeader{nResults} = {'FILE','PrDir','PrSpd','PrHDsp','RFX','RFY','RFDiam','Nthr','NSlp','Mthr','MSlp','DspLo','DspHi','Ntrials','HCorr','ROChCorr','NovarMean','NovarVar','VarMeam','VarVar'};
ResultsSummary{nResults} = 'NeuroPsycho_Curve_summary_SU_msi.dat';
ResultsMultipleDelims(nResults) = 1;

% choice probability by mean firing rate, redo after modifying CPvar/novar
% analysis code
nResults = nResults + 1;
ResultsExt{nResults} = 'cp_mean';
ResultsHeader{nResults} = {'FILE','lo_corr','CPnovar','CPvar','CPzero','Pzero','CPgrnd','Pgrnd','CPpref','CPnull','CPgrnd_phase','Pgrnd_phase','rPG','pPG'};;
ResultsSummary{nResults} = [INTEG_ANALYSIS_DIR 'CPSummary_SU_fr.dat'];
ResultsMultipleDelims(nResults) = 1;
% choice probability by pursuit gain
nResults = nResults + 1;
ResultsExt{nResults} = 'cp_pg';
ResultsHeader{nResults} = {'FILE','lo_corr','CPnovar','CPvar','CPzero','Pzero','CPgrnd','Pgrnd','CPpref','CPnull','CPgrnd_phase','Pgrnd_phase','rPG','pPG'};;
ResultsSummary{nResults} = [INTEG_ANALYSIS_DIR 'CPSummary_pg.dat'];
ResultsMultipleDelims(nResults) = 1;
% choice probability by mean firing rate, pursuit gain corrected
nResults = nResults + 1;
ResultsExt{nResults} = 'cp_pgcorr';
ResultsHeader{nResults} = {'FILE','lo_corr','CPnovar','CPvar','CPzero','Pzero','CPgrnd','Pgrnd','CPpref','CPnull','CPgrnd_phase','Pgrnd_phase','rPG','pPG'};;
ResultsSummary{nResults} = [INTEG_ANALYSIS_DIR 'CPSummary_SU_fr_pgcorrected.dat'];
ResultsMultipleDelims(nResults) = 1;
% pursuit gain
nResults = nResults + 1;
ResultsExt{nResults} = 'pg';
ResultsHeader{nResults} = {'FILE','MPgain','MPmedian','MPnear','MPfar','magnitude','pref','prefcat','eyewinX','eyewinY','reyewin','pDiff','vSlip0','vSlip180','pSlipDiff'};
ResultsSummary{nResults} = {'Z:\Data\MOOG\Chunky\Analysis\pursuit_gain.dat', 'Z:\Data\MOOG\Abbott\Analysis\pursuit_gain.dat'};
ResultsMultipleDelims(nResults) = 0;

% load population data
LoadPopulationData;

%% configure tuning curve data.
% here, loaded data is cell array of [cell # * tuning #]. Each element is
% a cell that has the content of each data file. 
nTC = 0; TCExt = {}; TCSummary = {}; TCMultipleDelims=[];
nTC = nTC + 1;
TCExt{nTC} = 'direc_curv_fit';
TCSummary{nTC} = TUNING_DIR(MonkOfInterest);
TCColumnIntegrity(iR) = 0;

nTC = nTC + 1;
TCExt{nTC} = 'spd_curv';
TCSummary{nTC} = TUNING_DIR(MonkOfInterest);
TCColumnIntegrity(iR) = 0;

nTC = nTC + 1;
TCExt{nTC} = 'hdsp_curv';
TCSummary{nTC} = TUNING_DIR(MonkOfInterest);
TCColumnIntegrity(iR) = 0;

nTC = nTC + 1;
TCExt{nTC} = 'mp_curv1';
TCSummary{nTC} = TUNING_DIR(MonkOfInterest);
TCColumnIntegrity(iR) = 0;

nTC = nTC + 1;
TCExt{nTC} = 'np_curves';
TCSummary{nTC} = '\NeuroPsychoCurves\';
TCColumnIntegrity(iR) = 0;

% load tuning curve data
LoadTuningCurves;

%% post-loading processing
% exclude rows with only NaNs
warning('Monkey 1 is 32');
bExc = all(isnan(aPD(:,[3:end])),2);
aPD = aPD(~bExc,:);
[g1 nSig1 nData1] = grpstats([is_sig(hdspCurveANOVA) is_sig(dirCurveANOVA) is_sig(mp_meanp)], aPD(:, MonkID), ...
    {'gname','sum','numel'})
sum(nSig1), sum(nData1)

% exclude cells which do not have direction tuning
bValid = ~isnan(aPD(:, dirCurveANOVA));
aPD = aPD(bValid,:);
cTC = cTC(bValid,:);

% exclude bidirectional neuron
bExc = ( (aPD(:,1) == 32 & aPD(:,2) == 314)) | ((aPD(:,1) == 32 & aPD(:,2) == 187) | ...
    (aPD(:,1) == 32 & aPD(:,2) == 206))
aPD= aPD(~bExc,:);
cTC = cTC(~bExc,:);

% re-generate cell idientifier
cCellName = {};
for iR=1:size(aPD,1)
    cCellName{iR,1} = sprintf('m%dc%d', aPD(iR, MonkID), aPD(iR, CellID));
end

% filters
bOppSign = aPD(:, mp_meanmPDI) .* aPD(:, hdsp_meanmPDI) < 0;
bMPBDSig = aPD(:,mp_meanp) < .05 & aPD(:,hdsp_meanp) < .05;

% groups
gCongOpp = [];
gCongOpp(bOppSign) = 1;
gCongOpp(~bOppSign) = 2;
gCongOpp(~bMPBDSig) = NaN;  % for only comparing Opp and Cong, make other NaN

%% numbers for paper
bM1 = aPD(:,MonkID) == 32;
bM2 = aPD(:,MonkID) == 31;
% dot size
atand((58.3/1024 * 4 ) / 33.1)

bDiscrim = ~isnan(aPD(:, thr_meanMthr));
aPD = aPD(bDiscrim,:);
cTC = cTC(bDiscrim,:);

% total # of neurons from each monkey
for mid=MonkOfInterest
    bMonk=aPD(:, MonkID) == mid;
    fprintf('Monk %d: %d\n', mid,nnz(bMonk));
end
size(aPD,1)

% neuronal, psychophysical (mean,sd) threshold for each monkey and t-test between monkeys
[meanD stdD monk nData] = grpstats(aPD(:, [thr_meanMthr thr_meanNthr]), aPD(:, MonkID), ...
    {'median','std','gname','numel'});

[g1 nSig1 nData1] = grpstats([is_sig(hdspCurveANOVA) is_sig(dirCurveANOVA) is_sig(mp_meanp)], aPD(:, MonkID), ...
    {'gname','sum','numel'})
sum(nSig1), sum(nData1)

%% Summary of neurometric performance
NThres_fr = aPD(:,thr_meanNthr);
b_outlier_fr = aPD(:,thr_meanNthr) > NTCrit;
NThres_fr(b_outlier_fr) = NTCrit;
setfig(2,2, 'N vs. P Threshold');
gna;
[n, center, median_x] = plot_histgrp(aPD(~b_outlier_fr,thr_meanNthr), aPD(~b_outlier_fr,MonkID), 0:10:200);
gna;
[n, center, median_x] = plot_histgrp(aPD(~b_outlier_fr,thr_meanMthr), aPD(~b_outlier_fr,MonkID), 0:10:200);
gna;
neuron_thres = aPD(:,thr_meanNthr);
neuron_thres(neuron_thres>500)=500;
plot_scatter(neuron_thres , aPD(:,thr_meanMthr), MonkID);
axis square; set(gca,'xlim',[5 500],'ylim',[5 500],'xscale','log','yscale','log');
line([5 500],[5 500],'color','k')
xlabel('Neuronal threshold (deg)'); ylabel('Psychophysical threshold (deg)');
gna;
plotsqscatter(abs(aPD(:, mp_meanmPDI)), aPD(:, thr_meanNthr), MonkID,[0 1], [10 500]); %, abs(aPD(:, mp_meanmPDI)), aPD(:, cp_meanCPgrnd), 'bo');
xlabel('|MP DSDI|'); ylabel('Threshold');
set(gca,'ylim',[10 500],'yscale','log');

%% Summary of choice probability
setfig(3,2, 'Choice Proabability Summary');
gna;
plot_histsig(cp_meanCPzero, aPD(:, cp_meanPzero) < 0.05, .2:.05:.8, 0.5)
% mean and t test
mCP = nanmean(aPD(:, cp_meanCPzero)); [h p] = ttest(aPD(:, cp_meanPzero)-.5);
add_title(sprintf('\n %.3f / (p=%.2f)', mCP, p));
grpstats(aPD(:, cp_meanCPzero),aPD(:,MonkID), 'mean')

gna;
CPgrnd_fr = aPD(:, cp_meanCPgrnd);
Pgrnd_fr = aPD(:, cp_meanPgrnd);
plot_histsig(cp_meanCPgrnd, aPD(:, cp_meanPgrnd) < 0.05, .2:.05:.8, 0.5)
% mean and t test
mCP = nanmean(aPD(:, cp_meanCPgrnd)); [h p] = ttest(aPD(:, cp_meanCPgrnd)-.5);
add_title(sprintf('\n %.3f / (p=%.2f)', mCP, p));

if bSave2File
    % save histogram of CPzero and CPgrnd
    x_CP = 0.0:0.05:1;
    CPcenter = x_CP(1:end-1) + diff(x_CP)/2;

    n_CPzero = histc(CPzero_fr(Pzero_fr >= 0.05), x_CP);
    n_CPzeroSig = histc(CPzero_fr(Pzero_fr < 0.05), x_CP);
    n_CPgrnd = histc(CPgrnd_fr(Pgrnd_fr >= 0.05), x_CP);
    n_CPgrndSig = histc(CPgrnd_fr(Pgrnd_fr < 0.05), x_CP);

    % save to file
    fOut = fopen([FIG_DATA_DIR 'CPHist.dat'],'w');
    fprintf(fOut, 'Center\tCPzero\tCPzeroSig\tCPgrnd\tCPgrndSig\tCPzeroX\tCPzeroY\tCPgrndX\tCPgrndY\n');
    for iR=1:(size(n_CPzero,1)-1)
        if iR == 1
            fprintf(fOut, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
                CPcenter(iR), n_CPzero(iR), n_CPzeroSig(iR), n_CPgrnd(iR), n_CPgrndSig(iR), ...
                nanmean(CPzero_fr), max(n_CPzero+n_CPzeroSig)*1.2, nanmean(CPgrnd_fr), max(n_CPgrnd+n_CPgrndSig)*1.2);
        else
            fprintf(fOut, '%f\t%f\t%f\t%f\t%f\n', CPcenter(iR), n_CPzero(iR), n_CPzeroSig(iR), n_CPgrnd(iR), n_CPgrndSig(iR));
        end
    end
    fclose(fOut);
end

% Fig. 5B CPgrnd vs. CPzero
gna;
plotsqscatter(cp_meanCPzero, cp_meanCPgrnd, []); %, rlim);
draw_refs(0, 0.5, 0.5);

CPzero_fr = aPD(:, cp_meanCPzero);
Pzero_fr = aPD(:, cp_meanPzero);
CPgrnd_fr = aPD(:, cp_meanCPgrnd);
Pgrnd_fr = aPD(:, cp_meanPgrnd);
CPgrndphase_fr = aPD(:, cp_meanCPgrnd_phase);
Pgrndphase_fr = aPD(:, cp_meanPgrnd_phase);

gna;
rlim=[min([CPgrndphase_fr; CPgrnd_fr]) max([CPgrndphase_fr; CPgrnd_fr])];
plotsqscatter(cp_meanCPgrnd, cp_meanCPgrnd_phase, [], rlim);
draw_refs(0, 0.5, 0.5);

gna;
plotsqscatter(cp_meanCPvar, cp_meanCPnovar,[]);
draw_refs(0, 0.5, 0.5);
gna;
[cols grp] = cols2grp(aPD(:, [cp_meanCPnovar cp_meanCPvar]), {'NOVAR','VAR'})
plot_histgrp(cols, grp, 0:.1:1, .5)
mNOVAR=nanmean(aPD(:, [cp_meanCPnovar]));
[h pNOVAR] = ttest(aPD(:, [cp_meanCPnovar])-.5);
mVAR=nanmean(aPD(:, [cp_meanCPvar]));
[h pVAR] = ttest(aPD(:, [cp_meanCPvar])-.5);
add_title(sprintf('\n NOVAR mean=%.2f (p=%.2f), VAR mean=%.2f (p=%.2f)', mNOVAR, pNOVAR, mVAR, pVAR));

