function [popcelldata] = ReadCellDataByHeader(filename, MonkOfInterest, CellOfInterest, ResultsHeader, nHeader, multi_delims)
% ReadCellData read typical cell data file
%  typical cell data file consists of one line of header, followed by
%  [htb 
popcelldata = {};

for iMonk = 1:length(MonkOfInterest)
    popcelldata{iMonk} = NaN(length(CellOfInterest{iMonk}), length(ResultsHeader)-1); % exclude FILE
end
nCol = length(ResultsHeader);

delimiter = '\t ,';

if ~exist('fmt','var') || isempty(fmt)
    % generate format according to the number of columns
    fmt = '%s';
    for iC=2:nCol
        fmt = [fmt '%f'];
    end
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

nData = length(cData); monkid = nan(nData,1); cid = nan(nData,1); runid = nan(nData,1);
for iR=1:length(cData{1})
    % in BR, m33c28r3.e1u1. c: status of cells, e: electrode u:unit r:run
%     tmp = sscanf(cData{1}{iR}, 'm%dc%dr%de%du%d');
    tmp = sscanf(cData{1}{iR}, 'm%ds%dr%de%du%d');
    
    if length(tmp) == 5
        monkid(iR,1) = tmp(1); cid(iR,1) = tmp(2); runid(iR,1) = tmp(3);
        electid(iR,1) = tmp(4); unitid(iR,1) = tmp(5);
    elseif length(tmp) == 3
        monkid(iR,1) = tmp(1); cid(iR,1) = tmp(2); runid(iR,1) = tmp(3);
        electid(iR,1) = NaN; unitid(iR,1) = NaN;
    else
        edit(filename)
        error('%d: failed to extract cell identifiers from [%s]. check read format or data file', iR, cData{1}{iR});
        %keyboard;
    end
end

% don't use dlmread. it cannot detect abnormal row (less elements)
data = cell2mat( cData(2:end) );

% check data integrity: empty value
if any(any(data == EMPTY_VAL))
    [iR, iC] = find(data == EMPTY_VAL)
    warning('Empty value in %s (%d, %d)', filename, iR(1), iC(1));
    keyboard
end

if size(data,2) ~= (length(ResultsHeader)-1)
    warning('loading %s, header size excluding FILE (%d) and data size(%d) do not match', filename, (length(ResultsHeader)-1), size(data,2));
    warning('Trim data size to header size');
    keyboard
    data = data(:, 1:(length(ResultsHeader)-1));
end

% iterate data and assign
for iR=1:size(data,1)
    iMonk = find(monkid(iR) == MonkOfInterest);
    if isempty(iMonk), continue; end;
    iCell = find(cid(iR) == CellOfInterest{iMonk});
    if isempty(iCell), continue; end;
    bCompareCols = ~isnan(popcelldata{iMonk}(iCell, :));
    if any(~isnan(popcelldata{iMonk}(iCell, :))) &&  ...  % existing data has non-NaN numbers
            all(isnan(popcelldata{iMonk}(iCell, :)) == isnan(data(iR, :) ) ) && ... % all NaNs are same
            ( all(popcelldata{iMonk}(iCell, bCompareCols) == data(iR, bCompareCols)) ) % all non-NaN are same
        %% fprintf(1,' Redundant data (c%d) already exist\n', filename, cid(iR));
    elseif any(~isnan(popcelldata{iMonk}(iCell, :)))      % either NaN are not same, or non-NaN are not same.
        fprintf(1,'New data in %s (c%d) will overwrite old data\n', filename, cid(iR));
    end
    
    % at any case, new data overwrites old data
    popcelldata{iMonk}(iCell, :) = [data(iR,:)]; % monkid(iR) cid(iR) runid(iR)];
end
return;