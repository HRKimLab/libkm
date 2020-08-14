function [popcelldata neuronkey] = ReadCellDataByKey(filename, ResultsHeader, nHeader, multi_delims)
% ReadCellDataKey read typical cell data file
%  [cellname, numbers, ..... ; cellname, numbers, ....]
% cellname is either m31c24r1 or m31c24r1e19u3 (multielectrode version)
% similar to textscan(), but check number of columns and
% examples:
% ReadCellDataByKey('hoho.dat',{'File','PrefDir','PrefSpd',...},1);
% ReadCellDataByKey('hoho.dat', 10,1);

% if header is cell array, use the number of elements as column number
if iscell(ResultsHeader)
    nCol = length(ResultsHeader);
% if it's a number, then it's the number of columns
elseif isnumeric(ResultsHeader)
    nCol = ResultsHeader;
end

delimiter = '\t ,';

% generate format according to the number of columns
fmt = '%s';
for iC=2:nCol
    fmt = [fmt '%f'];
end

EMPTY_VAL = -987.654;
fid = fopen(filename, 'r'); 
% read acoording to the format. data file should be very regirious, and
% this function should be able to detect any small problem in the data
% file. For that, don't use 'multipledelimsasone',1, and detect any empty
% field. there should not be any empty field. Just use it exceptionally
% deal with ill-formatted data file.
cData = textscan(fid,fmt, 'Delimiter', delimiter,'Headerlines', nHeader, ...
    'TreatAsEmpty',{'--'},'CommentStyle','%', 'EmptyValue', EMPTY_VAL, 'MultipleDelimsAsOne', multi_delims);
fclose(fid);

fprintf(1, 'read %s \n', filename);
% read neuron key. This part indirectly, but pretty well, check the
% unmatched number of columns for each row. 
% If a row have different columns of data, then cData{1} will not be the
% neuron identifier. so this part will generate error since tmp is empty
% array.
nData = size(cData{1},1); 
monkid = nan(nData,1); cid = nan(nData,1); runid = nan(nData,1); electid = nan(nData,1); unitid = nan(nData,1);
for iR=1:nData
    % in BR, m33c28r3.e1u1. c: status of cells, e: electrode u:unit r:run
    tmp = sscanf(cData{1}{iR}, 'm%dc%dr%de%du%d');
    if length(tmp) == 3
        % we cannot use NaN. for generalizing it to single electrode neuron key. 
        % NaN==(any number) is false.
        % set the electrode as 0 and unit as 1
        tmp(4) = 0; tmp(5) = 1; % tmp(4) = NaN; tmp(5) = NaN;
    elseif length(tmp) ~= 5
        edit(filename);
        error('Failed to get cell identifier. Check read format\n%s:%d [%s]', filename, iR, cData{1}{iR});
    end
    monkid(iR,1) = tmp(1); cid(iR,1) = tmp(2); runid(iR,1) = tmp(3);
    electid(iR,1) = tmp(4); unitid(iR,1) = tmp(5);
end

% read numeric data
data = cell2mat( cData(2:end) );

% check data integrity: empty value
if any(any(data == EMPTY_VAL))
    [iR, iC] = find(data == EMPTY_VAL);
    warning('Empty value in %s (%d, %d)', filename, iR(1), iC(1));
    keyboard
end

% check data integrity: number of columns
if size(data,2) ~= (nCol-1)
    warning('loading %s, header size excluding FILE (%d) and data size(%d) do not match', filename, (length(ResultsHeader)-1), size(data,2));
    warning('Trim data size to header size');
    keyboard
    data = data(:, 1:(length(ResultsHeader)-1));
end

% make neuron key
popcelldata = data;
neuronkey = [monkid cid runid electid unitid];
return;