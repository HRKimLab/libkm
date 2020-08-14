function [unitkey monkid cid runid electid unitid  recType] = ExtractUnitInfo(unitkey)
% ExtractUnitInfo extract numerical unit information from string
% BAK : m31c134r4  c: cell, id r: run id
% BlackRock : m33c28r3e1u1. c: status of cells, e: electrode u:unit r:run
% This function can be used to interpret both formats. When reading BAK format, 
% we cannot stuff electid and unit with NaNs because NaN==(any number) is false.
% Therefore, for BAK format, use electid=0 and unitid=1 

% 3/18/2014 HRK

% VirMEn_Def
% recording type
REC_TYPE_SU = 1;
REC_TYPE_FP = 2;
REC_TYPE_STIM = 3;

recType = [];
if ~isempty( findstr(unitkey, 'TT') ), recType = REC_TYPE_SU; end;
if ~isempty( findstr(unitkey, 'FP') ), recType = REC_TYPE_FP; end;
if ~isempty( findstr(unitkey, 'ST') ), recType = REC_TYPE_STIM; end;
if isempty(recType) recType = NaN; end

% convert _FP0_01 
if ~isempty(strfind(unitkey, 'TT'))
    unitkey = regexprep(unitkey, '_2_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_02
    unitkey = regexprep(unitkey, '_3_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_02
    unitkey = regexprep(unitkey, '_4_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_02
    unitkey = regexprep(unitkey, '_5_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_02
    unitkey = regexprep(unitkey, '_6_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_02
    unitkey = regexprep(unitkey, '_7_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_02
    unitkey = regexprep(unitkey, '_8_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_024
    unitkey = regexprep(unitkey, '_9_0','_0'); %% sometimes name is m4s29r1_TT2_2_02, not m4s29r1_TT2_02
end
unitkey = regexprep(unitkey, '_FP','e');
unitkey = regexprep(unitkey, 'FP','e');
unitkey = regexprep(unitkey, '_TT','e');
unitkey = regexprep(unitkey, 'TT','e');
unitkey = regexprep(unitkey, '_0','u');
unitkey = regexprep(unitkey, '_','u');
iComma = findstr(unitkey, ',');
if ~isempty(iComma), unitkey(iComma:end) = []; end;

% tmp = sscanf(unitkey, 'm%dc%dr%de%du%d');
tmp = sscanf(unitkey, 'm%ds%dr%de%du%d');
if length(tmp) == 3
    tmp(4) = -1; tmp(5) = -1;
elseif length(tmp) ~= 5
    warning('Failed to interpret unitkey %s', unitkey);
    tmp = ones(1,5) * -1;
    keyboard
end
% assign output
monkid = tmp(1); cid = tmp(2); runid = tmp(3);
electid = tmp(4); unitid = tmp(5);

unitkey = [monkid cid electid unitid];