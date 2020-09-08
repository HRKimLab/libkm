function [comb_rsp borders] = psths2array(psths, varname, dataname, sTrigger, sWin)
% serialized structure variable
% deviated from psth2rocarray
% dataname: column cell vector of unitname
% 2019 HRK
nF = size(dataname, 1);
nLen = inf;
% find maximum length
for iF = 1:nF
    mm(iF,:) = minmax([psths.(dataname{iF}).x]);
end

if ~is_arg('sTrigger'), sTrigger = 0; end;
if ~is_arg('sWin'), sWin = [-inf inf]; end;
[sTrigOut sWinOut] = psth2time(psths.(dataname{iF}), sTrigger, sWin)

if isnumeric(sTrigger) && sTrigger == 0 && isinf(sWin(1)), sWinOut(:,1) = max(mm(:,1)); end
if isnumeric(sTrigger) && sTrigger == 0 && isinf(sWin(2)), sWinOut(:,2) = min(mm(:,2)); end

nSerLan = NaN;
for iF = 1:nF
    psth = psths.(dataname{iF});
    nG = size(psth.mean, 1);
    tmp_serial = [];
    
    for iG = 1:nG
        bTOI = psth.x >= sWinOut(iG,1) & psth.x < sWinOut(iG,2);
        tmp = psth.(varname)(iG, bTOI)';
        tmp_serial = [tmp_serial; tmp];
        borders(iG) = length(tmp_serial);
    end
    if isnan(nSerLan), nSerLan = length(tmp_serial);
    elseif nSerLan ~= length(tmp_serial)
        error('serialized length (%d) of %s is different from other (%d)', ...
            len(tmp_serial), dataname{iF}, nSerLen);
    end
   % serialize it as a row vector(?, (1,N))
   roc_w_USRsp{iF,1} = tmp_serial';
end

% remove time bins which has at least one NaN responses (borders)
comb_rsp = cat(1, roc_w_USRsp{:});

setfig(2,2);
gna;
imagesc(comb_rsp);
bVC = all( ~isnan(comb_rsp), 1);
comb_rsp = comb_rsp(:, bVC);
gna;
imagesc(comb_rsp);

for iF = 1:nF
   roc_w_USRsp{iF,1} = comb_rsp(iF,:);
end