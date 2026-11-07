addpath( genpath('Y:\NeuRLab\paper_code_data\Mante2013\') )

%% RUN - Data loading
% The path should not include mante2013.
subjects = [100001 100002];
% do not use filters when loading data (use empty). 
% just load all saved data, and then filter below
all_dataname = [];
neuron_behavior_filt = [];
% load psths
cPSTH = {};
mp_types = [0 2];  % [0 1 2 3 4] ...
phases = [0 180];
for iMP = 1:numel(mp_types)
    for iP = 1:numel(phases)
        fname = sprintf('MotionParallaxFix_t%d_psth_phase%d_w80.mat', mp_types(iMP), phases(iP) );
        % ???? mp_type, phase? ?? ???? fname ??.
        dt = load_psth_files(fname, subjects,'analysis_root', 'Y:\NeuRLab\Analysis\', all_dataname, neuron_behavior_filt);
        % fname ???? dt? ??
        % I found that a few neurons were collected with more than 10 conditions.
        % for now, just use neurons with more than 10 conditions
        dt = filter_psth_by_n(dt, 'n_grp', 10);
        % double check if experimental conditions are [-9999 -2:.5:2] depths.
        % -9999 means no stimulus was presented.
        bV = structfun(@(x) all(x.ginfo.unq_grp == [-9999 -2:0.5:2]'), dt)
        % remove psths with different conditions
        cF = fieldnames(dt);
        fprintf(1, 'removed %d psths with different conditions\n', nnz(~bV) );
        % final dataset
        dt = rmfield(dt, cF(~bV))
        cPSTH{iMP, iP} = dt;
    end
end

% convert psths to state space array (nTime * nNeuron)
% rspTCN is (time * condition * neuron)
[ss_MP0 TCN_MP0 cMP0] = psth2ss(cPSTH{1,1});
[ss_MP180 TCN_MP180 cMP180] = psth2ss(cPSTH{1,2});
analyze_state_space( TCN_MP0, 'neuron_label', cMP0, ...
    'grp_label', dt.m15s100r1e1u1.ginfo.unq_grp_label, 'animation', 1);
analyze_state_space_orig( TCN_MP0, 'neuron_label', cMP0, ...
    'grp_label', dt.m15s100r1e1u1.ginfo.unq_grp_label, 'animation', 1);

%
ss_MP = [ss_MP0; ss_MP180]; 
TCN_MP = [TCN_MP0 TCN_MP180];
cMP = [cMP0(:); cMP180(:)];
cCond = [dt.m15s100r1e1u1.ginfo.unq_grp_label(:); dt.m15s100r1e1u1.ginfo.unq_grp_label(:)];

res = analyze_state_space( TCN_MP, 'neuron_label', cMP, ...
    'grp_label', cCond, 'animation', 1, 'traj_cmap', [cool(10); copper(10)]);


% TCN_MP * res.pca.coef
%% try TNC
TNC_MP = permute(TCN_MP, [1 3 2]);
TNC_MP0 = permute(TCN_MP0, [1 3 2]);
res_TNC = analyze_state_space_TNC( TNC_MP, 'neuron_label', cMP, ...
    'cond_label', cCond, 'animation', 1, 'traj_cmap', [cool(10); copper(10)]);

%% apply dim red.
pc_scores=[];
for iC = 1:size(TNC_MP0, 3)
	pc_scores(:,:,iC) = TNC_MP0(:,:,iC) * res.pca.coef;
end
pc_scores = permute(pc_scores, [1 3 2]);
figure
plot3_TCN(pc_scores(:,:,1:3))
view(2)
%% 
sampling_rate = 100;
nNeuron = 200;

iNeuron = 1:nNeuron;
tick_Time = 0:1/(sampling_rate):1000;
off_neuron = linspace(0, 5, nNeuron);

ss_rsp = 2 * sin(pi*tick_Time' + off_neuron); %  + cos(2*pi*tick_Time' + off_neuron);
ss_rsp(:, iNeuron > 100) = cos(2*pi*tick_Time' + off_neuron(iNeuron > 100));
% add noise
ss_rsp = ss_rsp + randn(size(ss_rsp)) * 0.01;

setfig(2,1);
gna;
imagesc(ss_rsp);
%
gna;
trig = find(mod(tick_Time, 2)' == 0) * 10;
plot_timecourseMD('stream', ss_rsp, trig(1:100), -200, 1500, [], 'sampling_rate', 100);

%%

rmpath('Y:\NeuRLab\paper_code_data\Mante2013\nansuite')

d = load('probe_recording_sample.mat', 'cSpikes', 'trial_start', 'rew_on');
% one plot per neuron
[ax avg_psths pop_psths] = plot_neuron_psths('timestamp', d.cSpikes , d.trial_start, -2000, 10000, [], ...
    'n_row',2,'n_col', 3,'event', d.rew_on,'event_header','RewOn'); % 'save_fpath', 'exp1',
% trial_start에 대해 align, reward_on을 표시

% call cluster psths separately to do statistcal test
cluster_psths(avg_psths.rate_rsp, 'test_diff', 0);

[ss_rsp rspTCN cF] = psth2ss(pop_psths);