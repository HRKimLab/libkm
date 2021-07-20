function save_h5_array(h5_fpath, data_var, data, varargin)
% DAQ2H5 convert .daq file to h5f file
% 2020 HRK
% 
compress = 5; % 0 - 9, 0: no compression. see h5create 'Deflate' option

assert(isnumeric(data), 'data should be numeric')
assert(data_var(1) == '/', 'data_var should begin with /');

if isempty(data)
    fprintf(1, '%s is empty. skip save_h5_array to %s\n', data_var, h5_fpath);
    return;
end

data_type = class(data);

% get proper chunk size
chunk_row = min( [1024*60*20 size(data, 1)]);
if chunk_row == 0, chunk_row  = 1; end
chunk_col = min( [1024*60*20 size(data, 2)]);
if chunk_col == 0, chunk_col = 1; end

if compress == 0 % no compression
    h5create(h5_fpath , data_var, size(data), 'Datatype', data_type);
else
    % at 1kHz frequency (use 1024), chunk about 20 mins data
    h5create(h5_fpath , data_var, size(data), 'Datatype', data_type, ...
        'Chunksize', [chunk_row chunk_col], 'Deflat', compress);
end
h5write(h5_fpath, data_var, data);


