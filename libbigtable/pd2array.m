function [apd ] = pd2array(first_day_dnames, nkeys, pd_res)
% plot across-session results (e.g., learning effect) from aPD table data structure
% first_day_dnames: {'m20s13r1', 'm12s4r1'}: sN is session #, increases by day
% nkeys : array of unitkey5 [mid sid rid eid uid] X # of observations
% pd_res: [# of observations X # of features] 
%
% 2018 HRK

assert( size(nkeys,1) == size(pd_res,1) );

start_session = NaN(200,1);
for iM = 1:numel(first_day_dnames)
    tmp = sscanf(first_day_dnames{iM}, 'm%ds%dr%d');    
    start_session( tmp(1) ) = tmp (2);
end
fprintf(1, 'get start session info of %d animals\n', nnum(start_session));

% anticipatory licking appears as animals learn the task
[session_id apd mid_list] = pd2per_animal_sb_session(nkeys, pd_res, [], start_session);
