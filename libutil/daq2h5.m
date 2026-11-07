function daq2h5(daq_fpath)
% DAQ2H5 convert lagacy NI DAQ toolbox .daq file to .daqinfo (mat file) and .daq2h5 file
%  hdf format compresses the raw voltage. file size ~ 20% of the original
%  .daq file.
%
%  HOW TO LOAD DATA:
%	daq_data = h5read([filepath '.daq2h5'], '/data');
%	daq_time = h5read([filepath '.daq2h5'], '/time');
%	abstime = h5read([filepath '.daq2h5'], '/abstime');
%   dat_info = load([filepath '.daq2info'], '-mat');
%
% 2025 HRK

% remove file extension
daq_fpath = daq_fpath(1:end-4);
daq_infopath = [daq_fpath '.daq2info'];
daq_h5path = [daq_fpath '.daq2h5'];

fprintf(1, 'load raw daq file %s...\n', [daq_fpath '.daq']);

% check if DAQ data file was truncated
warning('on', 'MATLAB:daqread:truncatedFile');
% check the daq file. if truncated, last warn is MATLAB:daqread:truncatedFile
daq_info = daqread([daq_fpath '.daq'],'info');
[lastmsg, lastid] = lastwarn;
if strcmp(lastid, 'MATLAB:daqread:truncatedFile')
    fprintf(1, 'daq file %s is truncated. do not convert\n', [daq_fpath '.daq'] );	
	return;
end

% load data 
tic;
[daq_data, daq_time, abstime] = daqread([daq_fpath '.daq']);
% [daq_data, daq_time, abstime] = daqread([daq_fpath '.daq']); daq_data = single(daq_data);
s_daq = toc;

% skip if both info file and h5 file exist
if exist(daq_infopath, 'file') && exist(daq_h5path, 'file') 
	disp(['Both ' daq_infopath '   ' daq_h5path ' exist. sanity check...']);
	
	%% load and sanity check
	daq_info_loaded = load(daq_infopath, '-mat');
	
	daq_data_loaded = h5read(daq_h5path, '/data');
	daq_time_loaded = h5read(daq_h5path, '/time');
	abstime_loaded = h5read(daq_h5path, '/abstime');
	
	b_pass_sanity_check = 0;
	
	% occasionally, data size is dfferent. check array size first
	if all(size(daq_data_loaded)) == all(size(daq_data)) && ...
			all(size(daq_time_loaded) == size(daq_time)) 
		b_pass_sanity_check = 1;
	end
	
	% check content only if array size matches
	if b_pass_sanity_check 
		b_pass_sanity_check = all(all(daq_data_loaded == daq_data)) && ...
		all(all(daq_time_loaded == daq_time)) && ...
		all(all(abstime_loaded == abstime));
	end
	
	if b_pass_sanity_check
		fprintf(1, 'Sanity check passed. Skip generating info and h5 files.\n');
		return;
	else
		fprintf(1, 'Sanity check failed.\nDelete %s and %s.\n', ...
			daq_infopath, daq_h5path);
		delete(daq_infopath)
		delete(daq_h5path);
	end
end

pause(0.5);

% save daqinfo
disp(['save daq info to ' daq_infopath]);
save(daq_infopath, 'daq_info', '-mat')


% save data
disp(['save daq data to ' daq_h5path]);
h5_save_array(daq_h5path, '/data', daq_data);
h5_save_array(daq_h5path, '/time', daq_time);
h5_save_array(daq_h5path, '/abstime', abstime);

disp(['Successfully generated: ' daq_fpath '.daq => ' daq_infopath ' and ' daq_h5path]);

fclose('all')

%% load and sanity check
daq_info_loaded = load(daq_infopath, '-mat');

daq_data_loaded = h5read(daq_h5path, '/data');
daq_time_loaded = h5read(daq_h5path, '/time');
abstime_loaded = h5read(daq_h5path, '/abstime');

assert(all(all(daq_data_loaded == daq_data)) && ...
	all(all(daq_time_loaded == daq_time)) && ...
	all(all(abstime_loaded == abstime)), 'daq2h5: sanity check failed');

fprintf(1, 'Sanity check passed.\n');

return