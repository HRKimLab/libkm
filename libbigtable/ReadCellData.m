function [data] = ReadCellData(filename, nHeader, fmt)
% ReadCellData read typical cell data file
%  typical cell data file consists of one line of header, followed by
%  [htb 
global gMAX_CELLNO gMonkIdx;
if isempty(gMAX_CELLNO) || isempty(gMonkIdx)
    error('Define gMAX_CELLNO and gMonkIdx first');
end

fid = fopen(filename, 'r');
if exist('fmt','var') && ~isempty(fmt)
    % read acoording to given format
    cData = textscan(fid,fmt, 'Delimiter', '\t ','multipledelimsasone',1, 'Headerlines', nHeader);
else
    % just read first column
    cData = textscan(fid,'%s%*[^\n]', 'Delimiter', '\t ','multipledelimsasone',1, 'Headerlines', nHeader);
end
fclose(fid);

ucid = NaN(length(cData), 1); monkid = nan(size(ucid)); cid = nan(size(ucid)); runid = nan(size(ucid));
for iR=1:length(cData{1})
    % in BR, m33c28r3.e1u1. c: status of cells, e: electrode u:unit r:run
    tmp = sscanf(cData{1}{iR}, 'm%dc%dr%d');
    monkid(iR,1) = tmp(1); cid(iR,1) = tmp(2); runid(iR,1) = tmp(3);
    % convert monkid and cid to ucid
    ucid(iR,1) = gMonkIdx(monkid(iR)) * gMAX_CELLNO + cid(iR);
end


if length(cData) > 1 % data already read using format
    data = cell2mat( cData(2:end) );
else % read data using dlmread function
    data = dlmread(filename, '\t', nHeader, 1);
end

data = [ucid data monkid cid runid];
return;