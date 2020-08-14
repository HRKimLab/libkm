function AppendColsToFile(fpath, cHeader, default_vals, line_range)
% AppendColsToFile(fpath, cHeader, default_vals, line_range)
% 3/20/2014
% check integrity of original file
[cOrigHeader tmp isHeader] = ReadDataFileHeader(fpath, 1);

fid_orig = fopen(fpath, 'r');
% create temporary file, and add columns
fid_new = fopen([fpath '_tmp'], 'w');


tline = fgetl(fid_orig)
iLine = 1;
while tline ~= -1
    if isHeader && iLine == 1
        fprintf(fid_new, tline);
        fprintf(fid_new, '\t%s', cHeader{:});
        fprintf(fid_new, '\r\n');
    else
        fprintf(fid_new, tline);
        fprintf(fid_new, '\t%f', default_vals);
        fprintf(fid_new, '\r\n');
    end
    
    tline = fgetl(fid_orig)
    iLine = iLine + 1;
end
fclose(fid_orig);
fclose(fid_new);

% check integrity of the new temporary file
[cOrigHeader tmp isHeader] = ReadDataFileHeader([fpath '_tmp'], 1);

% overwrite original file
movefile(fpath, [fpath '_backup']);
movefile([fpath '_tmp'], fpath);