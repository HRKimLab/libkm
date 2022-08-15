% a demo of Matlab functions for time-series data analysis
% 
% This demo consists of two parts. 
% First, it show how to plot timecourse data in a variety of different ways 
% using PLOT_TIMECOURSE, which is a handy and powerful raster + PSTH plotting function. 
% It computes PSTHs sorted by groups using either timestamp or steram data,
% plot them flexibly, and returns output with which we can save load easlity.
% you can load multiple PSTHs and plot in various ways.
% see files in libtimecourses/ folder for all the functions related to this functionality.
% 
% Second, it shows how to quantify PSTHs and perform population analysis. 
% it shows how to extracts numbers and saves them out of PSTHs in a batch run, 
% and then how to load and combine the quantification later for population
% analysis. From multiple subjects, plot results in various ways with first-step 
% statistical tests (e.g., nonparametric unpaired or paired test).
% see files in libpopulation/ folder for all files related to this.
%
% functions often have multiple options. Open each function and look at the first 
% few lines if you want to figure out all of the options.
% See also DEMO_POPULATION_ANALYSIS, PLOT_TIMECOURSE, PANEL, REGRESS_PERP
%
% 2019 HyungGoo Kim. 
%%%%%%%%%%
%% Part 1. single-session analysis
%%%%%%%%%%
%% Load an example session data
load('sample_session.mat', 'ms_time', 'lick','speed','DAsensor','expcond','event', 'position');
% ms_time: time points in microseconds for continuous data. 
% lick: timestamp for individual licks
% speed: continuous locomotion speed resampled at 1000Hz
% DAsensor: continuous dopamine sensor signals resampled at 1000Hz

% plot a raw session data
create_figure('Raw data', 0); % create figure of a letter size with a title
plot(ms_time, [speed' DAsensor']);
yl = ylim;
hold on;
plot(lick, yl(2) * 0.9 * ones(size(lick)), 'r.');
legend('Speed','DASensor', 'lick');
hold off;
title('an example single-session data');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plotting a signle-session PSTH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% look at behaviors or neural signals aligned by a specific event of interest 
% using plot_timecourse function (PSTHs)
% to be accurate, it's not a peri-stimulus time histogram but a moving average.
% but let's call it PSTH.
% create figure. This returns a figure with 2 X 2 axis. 
% use setpanel(2,2) for more advanced options
setfig(3,2); 
% Plot raster and averaged timecourse (PSTH) aligned by an event of interest
gna; % get the next axis. 
% plot_timecourse split the current axis and draw raster plot (top) 
% and PSTH (bottom)
ax = plot_timecourse('timestamp', lick, event.REWARD_CD, -5000, 4000);
% timestamp data�� lick�� reward�� ���� align, ������ reward-5000ms, ���� reward+4000ms
atitle(ax(1), 'lick aligned by Reward');
ylabel(ax(2), 'lick rate (licks/s)');
gna;
% Plot raster and PSTH, use time windows as vector variables
ax = plot_timecourse('timestamp', lick, event.REWARD_CD, event.TRIAL_START_CD, event.TRIAL_END_CD);
atitle('Using variable time window');
ylabel(ax(2), 'lick rate (licks/s)');

gna;
% Plot stream and averaged timecourse
ax = plot_timecourse('stream', speed, event.REWARD_CD, -5000, 4000);
% stream data�� speed�� reward�� ���� align, ������ reward-5000ms, ���� reward+4000ms
atitle('Continuous data');
ylabel(ax(2), 'Running speed (cm/s)');

gna;
% Plot sorted by experimental condition. 
% 6th parameter is a group variable (vector, size should be same as trigger)
ax = plot_timecourse('stream', DAsensor, event.VSTIM_ON_CD, -2000, event.REWARD_CD+3000, expcond);
% stream data�� DAsensor�� visual stimulus onset�� ���� align, ������ ���� VStim-2000ms����, ���� ������ reward+3000ms����
% expcond (speed of the visual scene)�� ���� sort �ؼ� ������.
% group variable (6th parameter)�� plot �� �� sorting �ϴ� ����
atitle('Sorted by exp. condition (speed)');
ylabel(ax(2), 'Response (z-score)');


gna;
% proide metadata about trial condition
tb_cond = table(expcond, 'VariableName', {'Speed'});
[ax psth ] = plot_timecourse('stream', DAsensor, event.VSTIM_ON_CD, -2000, event.REWARD_CD+3000, tb_cond);
% tb_cond�� �������� sort�ؼ� plot �ϱ�.
% tb_cond�� expcond�� labeling �� ��.
% plot_timecourse(~, expcond) �������� plot_timecourse(~,tb_cond) ������ plot ���� ����.

% psth.ginfo contains metadata about experimental conditions (group info)
% this is useful e.g., population plotting function can check whether experimental
% conditions are identical across multiple PSTHs
psth.ginfo

% note that psth contains subsampled time courses at 100Hz instead of
% 1000Hz. to save disk space and loading time. 'resample_bin' option can change it.
psth.x

%% Plot timecouse with advanced options
p = setpanel(3,2);
p.gnp;

% Plot sorted by experimental condition. 
% 6th parameter is a group variable (vector, size should be same as trigger)
% also, do statiscal test
% color squares represent time points when the response with the same color is
% significantly differernt from baseline 
% gray squares indicate time points when the responses are significantly
% different between groups
ax = plot_timecourse('stream', DAsensor, event.VSTIM_ON_CD, -2000, event.REWARD_CD+3000, expcond, 'test_diff', 1);
% 'test_diff'�� �������� ���ǹ����� �˾ƺ��� ���� statistical test�� �ϰڴٴ� �ǹ�
% �ؿ� color line�� �� ���� '���ǹ��ϰ� �ٸ���'�� �Ǵܵ� ������. (�� condition���� test ����)
% �뷫�����δ� Ư�� ������ error bar�� basline([-1 0])�� error bar�� �� ��ĥ��, 
% ��Ȯ�ϰԴ� p.value<0.05�϶�, ���ǹ��� �����Ͷ�� �Ǻ��Ѵ�.
atitle(ax(1), 'test stats');
ylabel(ax(2), 'Response (z-score)');

p.gnp;
% Plot timecourse, sorted by condition, with other other events superimposed
% (e.g., visual stimulus onset). event should be [nT X nEvent] array and
% event_header should be same as nEvent. It draws vertical lines at the
% median of event timings.
% you can use a different color map. 
% gP.cmap can be a function handle or cell array (gP.cmap{2} = hsv(2), used when group # = 2)
global gP, gP.cmap = @copper;
% 3rd return argument (psth) contains a detailed information about the PSTH (e.g., x, y, yerr)
[~, psth] = plot_timecourse('stream', speed, event.REWARD_CD, event.TRIAL_START_CD, event.TRIAL_END_CD, ...
    expcond, 'event', [event.VSTIM_ON_CD event.TRIAL_END_CD], 'event_header', {'VStimOn', 'TrialEnd'} );
% 'event'�� plot ����� �߰��� ǥ���� ���׵� (���⼭�� visual stimulus onset�� trial end�� ���� ������, �ʷϻ����� ǥ�õ�)
% 'event_header'�� �ش� event���� median�� �������� ���� �׸�
gP.cmap = [];
atitle('Change colormap');

p.gnp;
% trials sorted by expcond and trial duration => can be motor latency, etc.
[ax1, psth] = plot_timecourse('stream', speed, event.REWARD_CD, event.TRIAL_START_CD, event.TRIAL_END_CD, ...
    [expcond event.VSTIM_ON_CD-event.REWARD_CD], 'event', event.VSTIM_ON_CD, 'event_header', {'VStimOn'} );
% 2���� �������� sorting : expcond�� vstim_on - reward (���� column�� ���� ����(expcond)�� �켱��)
atitle('Sort by another variable');

p.gnp;
% Plot sorted by behavior (e.g, whether avg speed is lower than the median of the average)
% get average speed for each trial. use 'timestamp' for spikes
avg_speed_tr = conv2rate('stream', speed, event.TRIAL_START_CD, event.TRIAL_END_CD);
% �� trial�� average ���ϱ� (trial ���� ��� �ӵ� ���ϱ�, ����� 119x1)
% 3��°�� 4��° ���ڴ� �ݵ�� trial start / end �� �ʿ�� ����, ���ڷ� �跮ȭ�ϰ��� �ϴ�
% time window�� ���۰� ���� column vector�� ������ �ָ� �ȴ�. �׷��� �� column vector�� ���� ũ����
% rate ����� ���ϵ�.

% obtain median speed across trials
median_speed = median(avg_speed_tr);
% trial average��(119��) ���� median ���ϱ� (session�� median)

% creat a group variable
grp = avg_speed_tr < median_speed;
% use thresholded speed as a group variable
plot_timecourse('stream', speed, event.REWARD_CD, event.TRIAL_START_CD, event.TRIAL_END_CD, grp);
% trial average speed�� session median speed���� ������(�� trial�� ��ü session�� ���� ������, 1)��
% trial average steepd�� session median speed���� ũ�ų� ������ (�� trial�� ��ü session�� ���� ������, 0)
% �� ���� �����ؼ� plot �Ѵ�.
atitle('Sort by median speed');

p.gnp;
% plot response as a function of distance. In this case, x axis becomes
% position instead of time. if the size of the first arguemnt (position) is
% same as the size of the second argurment (DAsensor), then plot_timecourse
% does ???? plot (first arg = x(t), second arg = y(t)).
% since it is open-loop condition, I used distance from the trial start to
% the reward delivery. (once reward is given, animal's position does not change in open-loop 
% so taking average is not very useful)
plot_timecourse(position , DAsensor, event.VSTIM_ON_CD, -2000, event.REWARD_CD+3000, expcond, ...
    'test_diff', 1);
atitle('f(dist)');

% Save single-session timecourse results in a file. 
% If the file exists, it appends to it.
% So you can save PSTHs from multiple sessions in one file.
% to save disk space, it drops trial data, which can be changed by argument.
asave_psth('./sample_psth.mat', psth, 'm0s1r1');

% fourth argument = 1 (0/1, default:0) saves trial-to-trial data (psth.rate_rsp).
% this is by default off to save disk space and loading time.
% turn it on only if necessary.
asave_psth('./sample_psth_t2t.mat', psth, 'm0s1r1', 1);

% Load PSTHs from a saved file. I recommend to use a return value as a
% structure because it makes it easy to handle population data (see below)
d = load('./sample_psth.mat');
d_t2t = load('./sample_psth_t2t.mat'); % for comparison
% �� ���� ���غ��� : d.m0s1r1.rate_rsp �� d_t2t.m0s1r1.rate_resp �� �ٸ���. 
% rate_resp�� ��� trial data�� ��Ƶ� ��. d_t2t.m0s1r1.rate_resp���� ��� trial���� data�� ����ִ�.
% timestamp data�� �켱 moving average��(200ms time window�� 1ms�� �̵��ϸ鼭) continuous������ �����, 
% �̷��� ������� data�� trigger point�� �߽����� time window�� ���ؼ� 1ms ���� rate_resp�� stack �Ѵ�.
% stream data�� ���� continuous �ϱ⶧����, �� ��ü���� �ٷ� 1ms ������ data�� rate_resp�� stack �Ѵ�.
% ��κ��� ��� asave_psth���� 4th argument�� 'save_raw'�� 0���� �س��´�. 
% (rate_resp�� ũ�Ⱑ ũ�⶧���� ���� ũ�⸦ ���̱� ���ؼ�)

p.gna;
% split axis vertically
split_axes(gca, 1, 2);
% plot a loaded PSTH
plot_psma(d.m0s1r1, [],[], 'event_header', 'VStimOn');
atitle('Plot loaded PSTH');
% let's take a look at the fields of psth structure
d.m0s1r1

%% single-session, yet another advanced option
setfig(3,2);
ab = event.REWARD_CD; % aligned by
ab(grp == 0) = NaN; % NaNs are ignored

gna; % start
plot_timecourse('timestamp', lick, ab, -3000, 3000, expcond, 'win_len', 200);
% time window = 200ms

gna; % time window = 30ms
plot_timecourse('timestamp', lick, ab, -3000, 3000, expcond, 'win_len', 30);

gna; % do not plot errorbar ('patch','line','none')
plot_timecourse('stream', DAsensor, ab, -3000, 3000, expcond, 'errbar_type', 'none');


gna; % adjust range of color code in the image map (low 10% - high 10%).
% default is 1%
plot_timecourse('stream', DAsensor, ab, -3000, 3000, expcond, 'adjust_clim', 10);
% data�� noise ū�� ������ �װ� ǥ���ϱ� ���� color ������ �ſ� �о�����. 
% color ������ �о����� ��κ��� ���ǹ��� �����͵��� �� �߰��� ������ �ǰ�, ��������� ������ �� �Ȱ��� �ȴ�.
% �̰� �����ϱ� ���ؼ� clim�� �����Ѵ�. ���� ���, ���� 10%, ���� 10%�� �����ߴ�. 
% �̷��� �ϸ� noise�� ������� �����ؼ� plot �� �� �ִ�.

% if you just want to compute psth without plotting (faster)
[~, psth_only] = plot_timecourse('stream', DAsensor, ab, -3000, 3000, expcond, 'plot_type','none');
gna;
plot_psma(psth_only);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 2. plotting time courses from multiple-session data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot population PSTHs in in separate panels
% load example PSTHs. multiple psth structures were saved in one file.
% load_psth_files() load PSTHs from multiple files and combine them,
% assuming the standard folder structure.
d = load('GCaMP_TrialOn.mat');

% plot population psths across neurons 
plot_mpsth_xneuron(d, 'event_header','RewOn');
% �ϳ��� session data���� plot
% ���� trial�� average ���ϴ� ������ ���⼭ �ϴ� ���� �ƴϰ�,
% ���� �Լ����� �̹� ������ mean �� s.e.m. (shading) �� �̿��ؼ� plot�� ��.
% shading�� �� trial ���� noise level, �� s.e.m�� ��Ÿ�� error bar

% TODO: demo of loading (currently not working on demo)
% lick_VStimOn = load_psth_files('lick_ab_VStimOn.mat', ANIMAL_ID, all_dataname, neuron_behavior_filt); 
%% plot PSTHs together in one panel
setfig(2,2);
ax = gna;
% Plotting population timecouses (PSTHs). 
% shading is the stdandard error of the mean PSTHs.
plot_mpsths(d, 'event_header', 'RewOn');
% plot_mpsths_xneuron�� �� session �� ���Ǻ� trial���� ����� plot �ϴ� �Լ��̰�, 
% plot_mpsths�� session�� ���� ����� plot�ϴ� �Լ��̴�.
% �� plot���� shading�� session average�� ���Ҷ� ���� s.e.m

gna;
% see individual PSTHs
plot_mpsths(d, 'individual_psths', 1, 'event_header', 'RewOn');
% ���⼭ ǥ�õ� individual PSTHs�� �� session data�̴�.

gna;
% see as an color-coded image
plot_mpsths(d, 'individual_psths', 1, 'event_header', 'RewOn', 'plot_type','image');

% show a time window for quantification
% time window�� visualization �ؾ� �Ҷ� ���
shade_plot(ax, [-1 0]);

gna;
% if you want to do some baseline subtraction. baseline subtraction is done for each
% psth and group (within the psth) separately.
plot_mpsths(d, 'base_lim', [-1 0])

%% answers to quiz 3.3 :  +1 and -1 offset-ed results
asave_psth('./sample_psth_t2t.mat', psth, 'm0s1r1', 1);
psth.mean = psth.mean  + 1;
asave_psth('./sample_psth_t2t.mat', psth, 'm0s1r2', 1);
psth.mean = psth.mean  - 2;
asave_psth('./sample_psth_t2t.mat', psth, 'm0s1r3', 1);

d1 = load('sample_psth_t2t.mat');

setfig(1,3);
ax1 = gna;
plot_psma(d1.m0s1r1);
ax2 = gna;
plot_psma(d1.m0s1r2);
ax3 = gna;
plot_psma(d1.m0s1r3);

linkaxes([ax1, ax2, ax3], 'y');

setfig(2,1);
gna;
plot_mpsths(d1)
% 3�� run�� ���� average�� plot
gna;
plot_mpsths(d1, 'individual_psths', 1)
% 3�� run�� ���� �Ǽ����� ���� ǥ��
plot_mpsth_xneuron(d1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 3. analyze dataset organized in a table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Running different protocols (e.g., standard condition and
% speed-manipulation condition) results in a table-shaped dataset
% (# of animals * # of protocols).

% load table-shaped dataset information. This file is generated by
% downloading NeuRLab google
% drive/online_documents/training_log/example_dataset_table2 into a
% tab-separated file (.tsv)
[cD tD] = load_tabular_dataset_info ('Y:\NeuRLab\BatchFiles\example_dataset_table2 - sheet1.tsv', 'debug',1);

% test. get cell array of datanames using a tag 'VR_LASTDAY'
dnames_lastday = get_datanames(tD, 'VR_LASTDAY')
% 'VR_LASTDAY' ��� protocol�� �� mouse ids (sessions)

% load psths that contain all of the photometry data aligned by trial start
% (scene movement onset)
all_neuron_LocOnV = load('Z:\km_lab\libkm\libtimeseries\pop_neuron_LocOnV.mat')

% filter the whole psths based on the names. The names are retrieved by tag
% note that plot mpsths examines group information (ginfo) between psths
% (e.g., m110s9r2e0u1.ginfo vs. m123s10r1e0u1.ginfo )
% and tries to make sure that # of groups is group labels match each other.
% However, this is a soft-check and you should first put the right dataname
% in your table-shaped .tsv file.
%
% note that if the event information is saved in the individual psths(e.g., reward onset), 
% the median of the saved events can be shown by 'event_header' argument.
figure;
lastday_neuron_LocOnV = filter_psth(all_neuron_LocOnV, dnames_lastday)
% 'VR_LASTDAY' protocol�� ������ session���� photometry data�� �����´�.
plot_mpsths(lastday_neuron_LocOnV, 'event_header','RewOn');

% you can call function inside a function to make it more concise
figure;
plot_mpsths(filter_psth(all_neuron_LocOnV, get_datanames(tD, 'VR_LASTDAY')), 'event_header','RewOn');

% finally, you can use plot_mpsths_table function, by which you can plot
% PSTHs from multipls protocols in a single function call.
plot_mpsths_table(tD, {'VR_LASTDAY', 'VR_ONE_TP2','VR_SPD2'}, all_neuron_LocOnV, 'event_header','RewOn')
% �������� protocol�� �� protocol�� ������ session�鿡 ���� plot �Լ�.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% quantify and population analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Quantify results
% quantify using a time window (-1s - 0 relative to reward onset)
DA_bef_rew = mpsths2rate(d, 'RewOn', [-1 0]);
% reward ���� [-1 0]���� condition(0.5,1,2)���� session�� �� ��� (time window�� [-1 0])
% DA_ref_rew : [# of sessions * # of conditions]

% plot population results
figure;
plot_barpair(DA_bef_rew);
% ���� session(���� animal)�� ������ ������Ѽ� bar plot.
atitle('DA bef. rew');

% If things work well, write more sophiscated quantifying routine 
% in the single-session analysis routine and save there
% below is an example of saving population quantifications into a text file
cF = fieldnames(d);
SaveResults('sample_data_summary2.dat', cF, {'CELL', 'V1','V2','V3'}, DA_bef_rew);
% �̷��� ������ sample_data_summary2.dat�� line 406 section���� ���

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 4. More advanced functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot lick, locomotion speed, neural data aligned by reward onset
% this function subdivide a given panel, call plot_timecourse function iteratively 
% to plot results aligned by the same trigger.
% an argument whose size is the same as ms_time is considered as stream.
% Otherwise it is considered as timestamp data.
% use need panel.m file for setpanel() function
p = setpanel(1,2);
p1 = p.gnp;
[pp h_psths psths] = plot_mtimecourses(ms_time, event.REWARD_CD, event.TRIAL_START_CD, event.TRIAL_END_CD, expcond, ...
    lick, speed, DAsensor, 'n_row', 3, 'pp', p1, 'y_labels', {'Lick','Speed','DA'}, 'titles',{'Lick','Speed','DA'} );

%% Plotting simultaneously recorded large-scale neural data (e.g., Neuropixels or 2-photon microscopy)
d = load('probe_recording_sample.mat', 'cSpikes', 'trial_start', 'rew_on');
% one plot per neuron
[ax avg_psths pop_psths] = plot_neuron_psths('timestamp', d.cSpikes , d.trial_start, -2000, 10000, [], ...
    'n_row',2,'n_col', 3,'event', d.rew_on,'event_header','RewOn'); % 'save_fpath', 'exp1',
% trial_start�� ���� align, reward_on�� ǥ��

% 3 neurons superimposed together. need to implement different colors
[ax avg_psths pop_psths] = plot_neuron_psths('timestamp', d.cSpikes , d.trial_start, -2000, 10000, [], ...
    'n_row', 2, 'n_col', 3,'event', d.rew_on,'event_header','RewOn', 'n_per_plot', 3);

% call cluster psths separately to do statistcal test
cluster_psths(avg_psths.rate_rsp, 'test_diff', 0)

%% other advanced functionality to manipulate psth data
% these functions also process multiple PSTHs if the psth data is saved
% in a way I show in the next section.
setfig(2,2);
gna;
% serialzie PSTHs
% for PCA, clustering, or other purpose, it is often necessary to serialize
% (concatenate) PSTHs in different groups (conditions) into one PSTH.
[sr_psth sBorder] = serialize_psths(psth, -14, 3);
plot_psma(sr_psth); draw_refs(0, sBorder, NaN);
title('serialized PSTH');

% re-align PSTHs

% evaluate statement across PSTHs

%% Perform population analysis based on quantified data
% at this stage, most important thing is check redundancy and uniqueness of
% data (neuron, behavior, whatever should not be redundant)

% Load a big table array of [# of neuron X # of quantifications]
tb = readtable('sample_data_summary2.dat')
% line 359���� �����ߴ� ����
% reward ���� [-1 0]���� condition(0.5, 1, 2)���� session �� ��� ���ߴ� data���� ����ִ�.
% V1 = �ӵ� 0.5, V2 = �ӵ� 1, V3 = �ӵ� 2

setfig(3,3, 'population analysis', 0);

% Scatter plots on square axes for two-variable pairwise comparisons
gna;
plotsqscatter(tb.V1, tb.V2);
% x,y scale�� �Ȱ��� ���缭 plot �ϴ� �Լ�
% session(animal)���� pair�� data�� condition(V1,V2)�� ���� ���غ� �� �ִ�.
% �� ���, V2���� reward ������ DA�� V1���� reward ���� DA���� '���ǹ�'�ϰ� ũ�ٴ� ���� �� �� �ִ�.

% Scatter plots on free-shaped axes for two-variable pairwise comparisons
gna;
plot_scatter(tb.V2, tb.V3);
% plotsqscatter�� axis�� �Ȱ��� ���ߴµ�, plot_scatter�� x,y scale�� �ڵ������� ��������.

% historgram
gna;
[val grp] = cols2grp([tb.V1 tb.V2], [1 2]);
plot_histgrp(val, grp);
% condition���� histogram ���� ��Ÿ����.
% �̶� session(animal)���� pair�� �ȵǾ��ִ�.

% historgram. paired difference
gna;
plot_histgrp([tb.V1 - tb.V2], [], -1:.2:1, 0);
% pair�� data ���� ���� ���� V1-V2�� �ߴ�.

% Bar plots for N-variable pairwise comparisons
gna;
plot_barpair([tb.V1 tb.V2 tb.V3]);

% Bar plots for N-variable pairwise comparisons. 
% parametric test shows warning if normality condition is not satisfied
gna;
plot_barpair([tb.V1 tb.V2 tb.V3], [],  0, 'test_type','par');
% 'par' : ȸ�� ������ ���Ժ����� �̷�ٴ� �������� ���.

% Bar plots for N-variable unpaired comparisons
% serialize array data into value and group
[vals grp] = cols2grp([tb.V1 tb.V2 tb.V3], [1 2 3]);
gna;
plot_bargrp(vals, grp);

%% format and save plots to pdf files
% foramt figure to use it for presentation or paper
global gP
gP.show_title = 0; % do not show title

formatfig

% save it to pdf. it requres APPEND_PDFS and ghostscript installation
% fig2pdf('all');
