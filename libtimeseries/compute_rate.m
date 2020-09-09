function [x rate_rsp array_rsp base_rate] = compute_rate(data_type, ts_resp, trigger, trial_start, trial_end, varargin)
% compute_rate compute averaged activity based on time series data
% rate_rsp: after smoothing
% array_rsp: before smoothing
% 2015, HRK
win_len = 60;
bPlotRawCh = 0;
n_trial = size(trigger, 1);
base_sub_win = []; % window for baseline subtraction
distance_edge = [];
array_rsp = [];    % given array_rsp
x = [];            % given x for array_rsp (ms)

process_varargin(varargin);

base_rate = [];
% additional temporal margin to avoid cutoff of running average
if isempty(win_len)
    off_win_len = 0;
else
    off_win_len = win_len;
end
% check size of arguments
assert(size(trigger,1) == size(trial_start,1) || numel(trial_start) == 1, '# of triggger and trial_start should match');
assert(size(trial_start,1) == size(trial_end,1) || numel(trial_start) == 1 || numel(trial_end) == 1, '# of trial_start and trial_end should match');

% data_type is numeric array of x(t), such as position
if isnumeric(data_type) 
    if isvector(ts_resp)
        ts_resp = ts_resp(:);
        % x(t)
        [array_xt t1] = train2array_varwin(data_type, trigger, trial_start, trial_end);
        if numel(data_type) == numel(ts_resp);
            % ts_resp is stream
            % y(t)
            [array_yt t2] = train2array_varwin(ts_resp, trigger, trial_start, trial_end);
        else
            % ts_resp is timestamp
            % y(t)
            [~, array_yt] = ts2array(ts_resp, trigger, trial_start, trial_end);
        end
                
        x_range = minmax(array_xt(:));
        % for now, just create x dim increased by one.
        if ~isempty(distance_edge)
            x_edge = distance_edge;
        elseif diff(x_range) > 30
            x_edge = (round(x_range(1))-1):(round(x_range(end))+1);
        else
            x_edge = linspace((round(x_range(1))-1), (round(x_range(end))+1), 50);
        end
        n_edge = length(x_edge);
        % set x axis for x(t)
        x = x_edge + diff(x_edge(1:2)) / 2;
        % reconstruct array_yt based on x(t)
        rate_rsp = NaN(n_trial, size(x, 2));
        
        for iT = 1:n_trial
            % find bins for array_x
            [n, bin] = histc(array_xt(iT,:), x_edge);
            
            for iB = 1:n_edge
                % bV is a boolean flag for t indicating x_edge(iB) < x(t) <= x_edge(iB+1)
                bV = (bin == iB);
                % use bV to capture y(t) (rates at that timepoinsts)
                y_in_current_bin = array_yt(iT, bV);
                assert(n(iB) == length(y_in_current_bin));
                % take mean of y(t) having the same x(t) bins
                rate_rsp(iT, iB) = nanmean(array_yt(iT, bV));
                % take sum of y(t) having the same x(t) bins
                % rate_rsp(iT, iB) = nansum(array_yt(iT, bV));
            end
        end
    else % ts_resp is data array (e.i., psth) and x is already aligned time
        x = data_type;
        rate_rsp = ts_resp;
    end
   
    return
end

% data_type is not numeric, but string that specifies data type of ts_resp
switch(data_type)
    case 'timestamp'
        % generate trigger-aligned response array. expand TOI by time
        % window to avoid cutting off of average at both ends.
        
        if ~isempty(array_rsp) && ~isempty(x)
            % use given x and array_rsp
            assert(size(array_rsp, 2) == size(x, 2), 'array_rsp should be [n_trial * n_timepoints]');
%             assert(numel(unique(diff(x))) == 1, 'x should be equally spaced');
        else
            [x array_rsp] = ts2array(ts_resp, trigger, trial_start-off_win_len, trial_end+off_win_len);
        end
        % smoothing.
        % NaNs will be assigned if at least one in the sliding window is NaN
        if length(trial_start) == 1 && length(trial_end) == 1 && (trial_end-trial_start) <= 200
            warning('do not smooth timestamp data for PSTH');
            smooth_window = ones(1,1)/1;
            rate_rsp = array_rsp * 1000;
        elseif isnumeric(win_len)
            smooth_window = ones(1,win_len)/win_len; 
            rate_rsp = conv2(array_rsp, smooth_window, 'same') * 1000;
        elseif ischar(win_len)
            switch(win_len)
                case 'psp' % post-synaptic potential kernal
                    t = 0:150;
                    kn = (1 -exp(-t)) .* (exp(-t/20));
                    kn = [zeros(1, 150) kn];
                    smooth_window = kn ./ sum(kn) * 1000;
                    rate_rsp = conv2(array_rsp, smooth_window, 'same');
                case 'gauss'
                    t = -150:150;
                    kn = exp( -(t/100).^2 ) ;
                    smooth_window = kn ./ sum(kn) * 1000;
                    rate_rsp = conv2(array_rsp, smooth_window, 'same');
                otherwise
                    error('Unknown win_len: %s', win_len);
            end
        end
        % trim x, array_rsp, rate_rsp by win_len
        x = x( (off_win_len+1):end-off_win_len );
        array_rsp = array_rsp(:, (off_win_len+1):end-off_win_len );
        rate_rsp = rate_rsp(:, (off_win_len+1):end-off_win_len );
        
        % compute trial-by-trial baseline rate
        if ~isempty(base_sub_win)
            base_rate = mean(rate_rsp(:,x >= base_sub_win(1) & x < base_sub_win(2)), 2) ;
            rate_rsp = rate_rsp - repmat(base_rate, [1 size(rate_rsp, 2)]);
        end        
        
    case {'stream'}
        [array_rsp x] = train2array_varwin(ts_resp, trigger, trial_start, trial_end);
        % baseline subtraction
        if ~isempty(base_sub_win)
            if all(size(base_sub_win) == [1 2])
                base_rate = mean(array_rsp (:,x >= base_sub_win(1) & x < base_sub_win(2)), 2) ;
            elseif size(base_sub_win, 1) == size(array_rsp, 1)
                base_rate = base_sub_win;
            else
                error('Unknown base_sub_win type');
            end
            array_rsp = array_rsp - repmat(base_rate   , [1 size(array_rsp, 2)]);
        end        
        
        % no smoothing for continuouse stream data
        rate_rsp = array_rsp;

    case 'stream_lineplot'
        bPlotRawCh = true;
        [array_rsp x] = train2array_varwin(ts_resp, trigger, trial_start, trial_end);

        % no smoothing for continuouse stream data
        rate_rsp = array_rsp;
        
    otherwise
        error('Unknown data_type: %s', data_type);
end

if bPlotRawCh
    x = x / 30000;
else
    x = x / 1000;
end
