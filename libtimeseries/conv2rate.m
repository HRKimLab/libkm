function rate = conv2rate( ch_type, ch_data, onset, offset)
% convert either timestamp or steam data to rate
% HRK 2019
switch(ch_type)
    case 'timestamp'
        rate = ts2rate(ch_data, onset ,offset);
    case 'stream'
        rate = stream2rate(ch_data, onset, offset);
    otherwise
        error('Unknown convertion mode: %s', ch_type);
end

