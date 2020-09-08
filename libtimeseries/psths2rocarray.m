function comb_rsp = psth2rocarray(psths, fn);

nF = size(fn, 1);
nLen = inf;
% find maximum length
for iF = 1:nF
    nLen = min([nLen size(psths.(fn{iF}).roc_val, 2)]);
end

for iF = 1:nF
   tmp = psths.(fn{iF}).roc_val(:, 1:nLen)';
   roc_w_USRsp{iF,1} = tmp(:)';
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