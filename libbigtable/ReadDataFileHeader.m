function [cHeader strHeader isHeader] = ReadDataFileHeader(filepath, bCheckColumnIntegrity)
% [cHeader strHeader isHeader] = ReadDataFileHeader(filepath, bCheckColumnIntegrity) 
%   ReadFileHeader read file header and return cell array of header, and 
%   string 'FILE','PDIR' 
fid = fopen(filepath);

% tokenize first line and get number of columns
tline = fgetl(fid);
R = tline;
nHeader = 0;
nLine = 1;
cHeader = {}; strHeader = [];
delim = [' ,' char(9) char(10) char(13)]; % char(9): \t 13: \n 13: \r
while ~isempty(R)
    [T,R] = strtok(R,delim);
    % when space is after last header, it T = R = ''. check this case. 
    if length(T) == 0, continue; end;
    nHeader = nHeader + 1;
    cHeader{nHeader} = T;
    strHeader = [strHeader '''' T ''','];
end

strHeader(end) = [];

% are these string headers or just numbers?
isHeader = any(cellfun(@isempty, cellfun(@str2num, cHeader,'uniformoutput',false)));

if bCheckColumnIntegrity
    % OK. now test it with textscan
    tline = fgetl(fid);
    while tline ~= -1
        cBody = textscan(tline, '%s','delimiter','\t, ');
        if length(cBody{1}) ~= nHeader
            warning('# of columns (%d) ~= # of headers (%d)', length(cBody{1}), nHeader);
    %        keyboard
        end
        tline = fgetl(fid);
    end
end
fclose(fid);
