function daq2h5_folders(froot, varargin)

move_file = '';
force_convert = 0;
subfolder_list = 1500:-1:1000;

process_varargin(varargin);

for subfolder = subfolder_list
	fdir = [froot filesep num2str(subfolder) filesep 'virmen'];
	if ~isdir(fdir)
		warning([fdir ' should be a folder. Skip processing']);
		continue;
	end
	fprintf(1, 'Process folder %s\n', fdir);
	daq2h5_single_folder(fdir, 'move_file', move_file, 'force_convert', force_convert);
end