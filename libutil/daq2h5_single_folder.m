function daq2h5_single_folder(fdir, varargin)

move_file = '';
force_convert = 0;

process_varargin(varargin);

assert(isdir(fdir), [fdir ' should be a folder']);

finfo = dir([fdir filesep '*.daq']);

for iF = 1:numel(finfo)
	daq_fpath = fullfile(fdir, finfo(iF).name);
	if exist(daq_fpath)
		daq2h5(daq_fpath);
		
		if isempty(move_file)
			continue;
		end
		
		% absolute path
		if move_file(1) == '/' || move_file(2) == ':'
			fdir_dest = move_file;
		else % relative path
			fdir_dest = fullfile(fdir, move_file);
		end
	
		% create destination folder if not exists
		if ~isdir(fdir_dest), mkdir(fdir_dest); end
		
		fprintf(1, 'move file %s to %s\n', daq_fpath, fdir_dest);
		movefile(daq_fpath, fdir_dest);
	end
end