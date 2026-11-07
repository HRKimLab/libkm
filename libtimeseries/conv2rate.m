function rate = conv2rate( ch_type, ch_data, onset, offset)
% CONV2RATE convert either timestamp or steam data to rate (per second)
%  conv2rate( ch_type, ch_data, onset, offset) 
%     ch_type: 'timestamp' | 'stream' 
%     ch_data: data to be converted. 
%       For the stream data type, it assumes that ch_data is sampled at 1kHz.
%     onset:   a column vector of [n_obs * 1]. start of the time window in miliseond.
%     offset:  a column vector of [n_obs * 1]. end of the time window in milisecond.
%
%    Internally, it simply calls ts2rate or stream2rate depending on ch_type.
%
% RETURN VALUE:
%      rate:    a column vector of [n_obs * 1]. rate computed for each time
%        window.
%
% See also TS2RATE, STREAM2RATE

% HRK 2019
switch(ch_type)
    case 'timestamp'
        rate = ts2rate(ch_data, onset ,offset);
    case 'stream'
        rate = stream2rate(ch_data, onset, offset);
    otherwise
        error('Unknown convertion mode: %s', ch_type);
end

