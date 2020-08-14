function addcol2datfile(fpath, new_headers)
% add NaN columns to existing .dat file
% 12/2/2016 HRK
f_read = fopen(fpath,'r');
f_out = fopen([fpath '_a'], 'w');

% append headers
sHeader = fgetl(f_read);
append_nans = '';
for iH = 1:length(new_headers)
    sHeader = [sHeader '\t' new_headers{iH}];
    append_nans = [append_nans '\tNaN'];
end

fprintf(f_out, [sHeader '\r\n']);

sL = fgetl(f_read);
% append data
while sL ~= -1
    sL = [sL append_nans];
    fprintf(f_out, [sL '\r\n']);
    sL = fgetl(f_read);
end

fclose(f_read);
fclose(f_out);