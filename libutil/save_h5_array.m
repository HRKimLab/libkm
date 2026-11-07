function save_h5_array(h5_fpath, data_var, data, varargin)
% wrapper function for backward compatibility
h5_save_array(h5_fpath, data_var, data, varargin{:})
