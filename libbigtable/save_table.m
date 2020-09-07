function save_table(fpath, tbRow, unitkey)
% save table data structure
% 2019 HRK

global data

% use the unitname of the loaded data if not given
if ~is_arg('unitkey')
    unitkey = data.id.unitname;
end

% use analysis dir of the loaded data if not given
[fdir fn] = fileparts(fpath);
if isempty(fdir)
    fdir = data.files.analysis_dir;
end

% save it to a text file
StoreResults(fdir, [fn '.dat'], [], unitkey, ...
    tbRow.Properties.VariableNames, tbRow{:,:} );