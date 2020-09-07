function fp_info = plot_field_potential(aFP, trigger, start_win, end_win, varargin)
% plot field potnetial alighed by triggers
% aFP is [n_sample * n_channel] array
%
% 2020 HRK

realign = 0;            % re-align spike waveform based on the peak or though of the best chennel
plot_mode = 'all';      % 'best_unref';
sampling_freq = 30000;  % Open Ephys default is 30kHz
sub_avg = 0;            % subtract average

process_varargin(varargin);

assert(start_win < 0, 'start_win should be negative');
assert(end_win > 0, 'end_win should be positive');
x = (start_win:end_win)/sampling_freq * 1000;

% tim triggers
bV = trigger + start_win > 0 & trigger + end_win <= size(aFP, 1);
trigger = trigger(bV);
if ~all(bV)
    fprintf(1, 'plot_field_potential: use %d out of %d triggers\n', nnz(bV), numel(bV) );
end
hold on;
cm = brighter(jet(size(aFP, 2)), 2);

% get waveform indice
[xxS yyS] = meshgrid(trigger, start_win:end_win);
% get the best raw channel based on the range of the signal
for iCC = 1:4
    a = aFP(:, iCC);
    WFs = a( xxS + yyS);
    if sub_avg
        WFs = bsxfun(@minus, WFs, mean(WFs, 1) );
    end
    v_range(iCC, :) = prctile(WFs(:), [5 95]);
end

% get the channel with a largest peak-to-peak signal.
[~, best_unref_channel] = max( diff(v_range, [], 2) );
% decide whether to use trough(1) or peak (2) for alignment
[~, best_unref_trough_or_peak] = max( abs(v_range(best_unref_channel, :) ));
% determine a function to use for aligning
if best_unref_trough_or_peak == 1
    align_func = @min;
elseif best_unref_trough_or_peak == 2
    align_func = @max;
else, error('Unknown value');
end

% get shift amount based on the best raw channel
a = aFP(:, best_unref_channel);
WFs = a( xxS + yyS);
if sub_avg
    WFs = bsxfun(@minus, WFs, mean(WFs, 1) );
end
[~, tM] = align_func(WFs,[], 1);
% compute time shift based on the min or max of the waveform

if realign
    t_shift = tM + start_win - 1;
else
    t_shift = zeros(size(tM));
end

% re-compute waveform indice based on the re-alignment
[xxS yyS] = meshgrid(trigger + t_shift', start_win:end_win);

switch(plot_mode)
    case 'all'
        % plot waveforms
        h_WF = []; unref_WF = [];
        for iCC = 1:4
            a = aFP(:, iCC);
            WFs = a( xxS + yyS) ;
            if sub_avg
                WFs = bsxfun(@minus, WFs, mean(WFs, 1) );
            end
            h_WF(:,iCC) = plot(x,  WFs,'color', cm(iCC,:) );
            plot(x,  mean( ( WFs ),2) ,'color', darker(  cm(iCC,:), 3) )
            unref_WF(:,:, iCC) = WFs;
            unref_avg_WF(:, iCC) = mean( ( WFs ),2);
        end
        stitle('300-7kHz BF, accurate trigger, best: %d (%s)', best_unref_channel, func2str(align_func) );
        legend(h_WF(1,:), 'CH1','CH2','CH3','CH4');
        draw_refs(0, 0, NaN);
        xlabel('Time (ms)');
        
        fp_info.unref_WF = unref_WF;
        fp_info.unref_avg_WF = unref_avg_WF;
    case 'best_unref'
        avg_wf.xl = [start_win end_win];
        avg_wf.best_unref_WF = train2array_fixwin(aFP(:,best_unref_channel)', ...
            trigger, avg_wf.xl);
        avg_wf.x = (avg_wf.xl(1):avg_wf.xl(2)) / sampling_freq;
        plot_linesep(x, avg_wf.best_unref_WF' , 300);
        xlabel('Time (ms)'); ylabel('Signal (uW)');
        stitle('Best unref CH (%d), 300-7kHz BF, approx. trigger (drift)', best_unref_channel);
%         shade_plot(gca, [-0.5 0.5]);
%         draw_refs(0,0,NaN);
        
    otherwise
        error('Unknown plot_mode: %s', plot_mode);
end

xlim([start_win end_win] / sampling_freq * 1000);

fp_info.best_unref_channel = best_unref_channel ;
fp_info.best_unref_trough_or_peak = best_unref_trough_or_peak;

