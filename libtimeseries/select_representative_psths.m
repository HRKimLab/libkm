function [psths_out nSubject] = select_representative_psths(psths, varargin)
% select representative psths for each subject
% 2020 HRK

per_subject = []; % first N psths. (TODO: last N if negative)

process_varargin(varargin);

cF = fieldnames(psths);
nF = numel(cF);
ukey = str2unitkey5(cF);

% sort unit keys
[~, iS] = sortrows(ukey);
cF = cF(iS);
ukey = ukey(iS, :);

% TODO need to change it to incorporate repo_id (use munique)
unq_mids = unique(ukey(:,1));
nSubject = numel(unq_mids);
bV = false(nF, 1);
for iM = 1:numel(unq_mids)
   iSub = find(ukey(:,1)' == unq_mids(iM));
   nSes = min([numel(iSub) per_subject]);

   if nSes ~= per_subject
       warning('m%d has %d (< %d) representative psths\n', unq_mids(iM), nSes, per_subject);
   end
    % take first nSes fields
   for iF = iSub(1:nSes)
        psths_out.(cF{iF}) = psths.(cF{iF});
   end
end

fprintf(1, '%d representative psths selected from total %d psths, %d subjects\n', ...
    nfields(psths_out), nF, numel(unq_mids));
