function [session_ids padata mid_list] = pd2pa(aPD, results, eid_uid_filter, start_sid)
% from population array (aPD) to per-animal data sorted by session #
% start_sid(mid) : set start session for animal mid
% 7/24/2016

KEY_COLS = evalin('base', 'KEY_COLS');

if ~is_arg('start_sid') 
    start_sid = ones(max(aPD(:,1)), 1); 
end;
assert(size(aPD,1) == size(results, 1));
if ~is_arg('eid_uid_filter'),  eid_uid_filter = [-1 -1]; end
assert(all(size(eid_uid_filter) == [1 2]));

mid_list = unique(nonnans( aPD(:,1)));
num_animal = length(mid_list);
max_session = nanmax(aPD(:,2));
nResults = size(results, 2);

pcd_colname = evalin('base', 'pcd_colname');

padata = NaN(num_animal, max_session, nResults);

for iR = 1:size(results, 2)
    iA = 1;
    for mid = mid_list(:)'
        % only take into account behaviors
        if strcmp(pcd_colname{3}, 'ElectID')
            bV = aPD(:,1) == mid & aPD(:,KEY_COLS(end-1)) == eid_uid_filter(1) & aPD(:,KEY_COLS(end)) == eid_uid_filter(2);
        else
            bV = aPD(:,1) == mid;
        end
        res = results(bV, iR)';
        % get session id relative to start_sid
        sid = aPD(bV, 2) - start_sid(mid) + 1;
        % use results only with positive sid
        bPosSid = sid > 0;
        if numel( sid(bPosSid) ) ~= numel(nonnan_unique(sid(bPosSid)))
            sid(bPosSid);
            redundant_sids = setdiff( sid(bPosSid) , nonnan_unique(sid(bPosSid)) );
            warning('m%ds[%s] is redundant. data will be overwritten.', mid, sprintf('%d ', redundant_sids(:)));
        end
        padata(iA,  sid(bPosSid), iR) = res(bPosSid);
        iA = iA + 1;
    end
end

% remove padata if actual session is smaller than max_session due to
% start_sid
iEleSession = [];
for iS = size(padata,2):-1:1
    if all(all(isnan(padata(:,iS,:)), 1), 3)
        iEleSession = [iEleSession iS];
    else
        break; % look at backward and stop
    end
end
padata(:, iEleSession,:) = [];

session_ids = 1:size(padata, 2);